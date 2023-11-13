#!/usr/bin/env python3

import re
import argparse
from web3 import Web3


def calculate_storage_key(key: str, slot: str) -> str:
    """
    Calculates the storage key for a mapping
    https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#mappings-and-dynamic-arrays
    :param key: Key to calculate storage slot for in the mapping (hex)
    :param slot: Slot of the mapping (hex)
    :return: Keccak256 hash of the key and slot (hex)
    """
    def h2b(x: str) -> bytes:
        """
        Converts hex to bytes
        :param x: Hex string
        :return: Bytes with padding to 32 bytes
        """
        return bytes.fromhex(re.sub("^0x", "", x).lower().rjust(64, '0'))
    return  Web3.keccak(h2b(key) + h2b(slot)).hex()


if __name__ == "__main__":
    args = argparse.ArgumentParser()
    args.add_argument("--key", type=str, required=True, help="Key to calculate storage slot for in the mapping (hex))")
    args.add_argument("--slot", type=str, required=True, help="Slot of the mapping (hex)")
    args = args.parse_args()

    value = calculate_storage_key(args.key, args.slot)
    print(f"Storage key: {value}")
