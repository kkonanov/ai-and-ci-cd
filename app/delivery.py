"""Калькулятор доставки."""

BASE_PRICE = {"Зион": 100, "Хоббитон": 150}
EXPRESS_EXTRA = 150
FREE_FROM = 5000


def delivery_price(city: str, order_sum: int, express: bool = False) -> int:
    """Стоимость доставки в морковках."""
    if city not in BASE_PRICE:
        raise ValueError(f"Нет доставки в город {city}")
    if order_sum >= FREE_FROM and not express:
        return 0
    price = BASE_PRICE[city]
    if express:
        price += EXPRESS_EXTRA
    return price
