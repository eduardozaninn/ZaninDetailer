from fastapi import Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

_FIELD_LABELS = {
    "full_name": "Nome completo",
    "phone": "WhatsApp",
    "license_plate": "Placa do veículo",
    "vehicle_brand_model": "Marca e modelo do veículo",
    "name": "Nome",
    "description": "Descrição",
    "price": "Preço",
    "duration_minutes": "Duração",
    "scheduled_start": "Data/horário",
    "service_id": "Serviço",
    "email": "E-mail",
    "password": "Senha",
}


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    first_error = exc.errors()[0]
    field = str(first_error["loc"][-1])
    label = _FIELD_LABELS.get(field, field)
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": f"Verifique o campo \"{label}\": valor inválido ou ausente."},
    )
