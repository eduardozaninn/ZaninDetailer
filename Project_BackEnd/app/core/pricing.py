from decimal import Decimal

VALID_VEHICLE_SIZES = ("hatch_sedan", "suv_medio", "suv_grande")

VEHICLE_SIZE_SURCHARGE: dict[str, Decimal] = {
    "hatch_sedan": Decimal("0"),
    "suv_medio": Decimal("20"),
    "suv_grande": Decimal("35"),
}
