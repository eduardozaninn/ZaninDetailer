from datetime import datetime
from decimal import Decimal

from sqlalchemy import and_, exists, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.appointment import Appointment, AppointmentHistory, AppointmentStatus
from app.models.client import Client


class AppointmentRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, appointment_id: int) -> Appointment | None:
        result = await self._session.execute(
            select(Appointment)
            .where(Appointment.id == appointment_id)
            .options(
                selectinload(Appointment.client),
                selectinload(Appointment.service),
                selectinload(Appointment.history),
            )
        )
        return result.scalar_one_or_none()

    async def get_conflicting(
        self,
        start: datetime,
        end: datetime,
        exclude_id: int | None = None,
        for_update: bool = False,
    ) -> list[Appointment]:
        conditions = [
            Appointment.status.notin_([AppointmentStatus.CANCELLED]),
            Appointment.scheduled_start < end,
            Appointment.scheduled_end > start,
        ]
        if exclude_id:
            conditions.append(Appointment.id != exclude_id)

        query = select(Appointment).where(and_(*conditions))
        if for_update:
            query = query.with_for_update()

        result = await self._session.execute(query)
        return list(result.scalars().all())

    async def create(
        self,
        *,
        client: Client,
        service_id: int,
        scheduled_start: datetime,
        scheduled_end: datetime,
        total_price: Decimal,
        vehicle_surcharge: Decimal = Decimal("0"),
    ) -> Appointment:
        appointment = Appointment(
            client=client,
            service_id=service_id,
            scheduled_start=scheduled_start,
            scheduled_end=scheduled_end,
            total_price=total_price,
            vehicle_surcharge=vehicle_surcharge,
            status=AppointmentStatus.PENDING,
        )
        self._session.add(appointment)
        await self._session.flush()
        await self._session.refresh(appointment)
        return appointment

    async def add_history(
        self,
        appointment: Appointment,
        *,
        previous_status: str | None = None,
        new_status: str | None = None,
        previous_start: datetime | None = None,
        new_start: datetime | None = None,
        reason: str | None = None,
        changed_by: str,
    ) -> None:
        entry = AppointmentHistory(
            appointment_id=appointment.id,
            previous_status=previous_status,
            new_status=new_status,
            previous_start=previous_start,
            new_start=new_start,
            reason=reason,
            changed_by=changed_by,
        )
        self._session.add(entry)
        await self._session.flush()

    async def save(self, appointment: Appointment) -> Appointment:
        await self._session.flush()
        await self._session.refresh(
            appointment,
            attribute_names=["client", "service", "history"],
        )
        return appointment
    
    async def exists_for_service(self, service_id: int) -> bool:
        result = await self._session.execute(
            select(exists().where(Appointment.service_id == service_id))
        )
        return result.scalar_one()

    async def list_by_date_range(
        self, start: datetime, end: datetime
    ) -> list[Appointment]:
        result = await self._session.execute(
            select(Appointment)
            .where(
                Appointment.scheduled_start >= start,
                Appointment.scheduled_start < end,
            )
            .options(
                selectinload(Appointment.client),
                selectinload(Appointment.service),
                selectinload(Appointment.history),
            )
            .order_by(Appointment.scheduled_start)
        )
        return list(result.scalars().all())
    