import pytest

from app.delivery import delivery_price


def test_zion_regular():
    assert delivery_price("Зион", 1200) == 100


def test_express_delivery():
    assert delivery_price("Зион", 1200, express=True) == 250


def test_free_from_5000():
    assert delivery_price("Зион", 5000) == 0


def test_unknown_city():
    with pytest.raises(ValueError):
        delivery_price("Мордор", 1200)
