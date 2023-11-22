import json
from web3.auto import w3
from pathlib import Path

from .storage_key import calculate_storage_key

OUTPUT_DIR = Path(__file__).parent.parent / "output"


class Contract:
    def __init__(self, name: str, address: str, balance: int | str = 0):
        self.name = name
        self.address = address
        if len(address) == 40:
            self.address = "0x" + address
        if balance == "max":
            balance = hex(2**256 - 1)
        else:
            balance = int(balance)
            if balance > 0:
                balance = w3.to_wei(balance, "ether")
        self.balance = balance
        self.path = OUTPUT_DIR / f"{name}"
        self.code = "0x" + self.read_bin_runtime()
        self.layout = self.read_storage()["storage"]
        self.storage = {}

    def read_bin_runtime(self) -> str:
        with open(self.path / f"{self.name}.bin-runtime", "r") as f:
            return f.read()

    def read_storage(self) -> dict:
        with open(self.path / f"{self.name}_storage.json", "r") as f:
            return json.load(f)

    def get_layout(self, label: str) -> dict:
        for v in self.layout:
            if v["label"] == label:
                return v
        raise Exception(f"Layout not found for {label}")

    def convert_value(self, value) -> str:
        if isinstance(value, int) or isinstance(value, bool):
            return '0x' + hex(value)[2:].rjust(64, "0")
        if not isinstance(value, str):
            raise Exception("Value must be int, bool or str")
        if value.startswith("0x"):
            value = value[2:]
        return '0x' + value.rjust(64, "0")

    def set_value(self, label: str,  value) -> None:
        layout = self.get_layout(label)
        if layout["offset"] != 0:
            raise Exception("The offset is not supported yet")
        if layout["type"].startswith("t_mapping"):
            raise Exception("The type is a mapping")
        # Calculate the key
        key = self.convert_value(layout["slot"])
        # Set the key
        self.storage[key] = self.convert_value(value)

    def set_mapping_value(self, label: str, key, value) -> None:
        layout = self.get_layout(label)
        if layout["offset"] != 0:
            raise Exception("The offset is not supported yet")
        if not layout["type"].startswith("t_mapping"):
            raise Exception("The type is not a mapping")
        # Calculate the key
        key = calculate_storage_key(key, self.convert_value(layout["slot"]))
        # Set the key
        self.storage[key] = self.convert_value(value)

    def get_storage(self) -> dict:
        return self.storage

    def json(self) -> dict:
        return {
            "code": self.code,
            "storage": self.storage,
            "balance": str(self.balance),
        }

    def __str__(self):
        return f"{self.name} ({self.address})"
