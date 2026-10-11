from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '9a1f2c3d4e5b'
down_revision: Union[str, Sequence[str], None] = '6558a3fd1d7f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'clients',
        sa.Column('vehicle_size', sa.String(length=20), nullable=False, server_default='hatch_sedan'),
    )
    op.add_column(
        'appointments',
        sa.Column('vehicle_surcharge', sa.Numeric(10, 2), nullable=False, server_default='0'),
    )


def downgrade() -> None:
    op.drop_column('appointments', 'vehicle_surcharge')
    op.drop_column('clients', 'vehicle_size')
