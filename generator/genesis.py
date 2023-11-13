import json
from web3.auto import w3

from .contract import Contract

BASIC_CONFIG = {
    "config": {
        "chainId": 0,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "clique": {
            "period": 0,
            "epoch": 30000
        }
    },
    "difficulty": "1",
    "gasLimit": "8000000",
    "extraData": f"0x{'0' * 236}",
    "alloc": {}
}


class GenesisGenerator:

    def __init__(
            self,
            miner_address: str,
            chain_id: int = 97453,
            difficulty: str = "1",
            gas_limit: str = "8000000",
            miner_balance: str = None,
            period: int = 0,
            epoch: int = 30000,
    ) -> None:
        self.conf = BASIC_CONFIG.copy()
        self.conf["config"]["chainId"] = chain_id
        self.conf["difficulty"] = difficulty
        self.conf["gasLimit"] = gas_limit
        self.conf["config"]["clique"]["period"] = period
        self.conf["config"]["clique"]["epoch"] = epoch
        if len(miner_address) == 40:
            miner_address = "0x" + miner_address
        self.miner_address = miner_address
        self.add_account(miner_address, miner_balance)
        self.add_extra_data()

    def add_account(self, address: str, balance: int) -> None:
        wei = w3.to_wei(balance, "ether")
        if len(address) == 40:
            address = "0x" + address
        self.conf["alloc"][address] = {"balance": f"{wei}"}

    def add_extra_data(self) -> None:
        data = "0" * 64
        data += self.miner_address[2:]
        data = data.ljust(236, "0")
        self.conf["extraData"] = f"0x{data}"

    def add_contract(self, contract: Contract) -> None:
        self.conf["alloc"][contract.address] = contract.json()

    def save(self, path: str) -> None:
        with open(path, "w") as f:
            json.dump(self.conf, f, indent=4)


def main():
    miner_address = "0x3efEba5D4B05b947df4A95D24C6671baDaAD1fc9"
    miner_balance = 100
    genesis = GenesisGenerator(miner_address, miner_balance=miner_balance)
    genesis.save("genesis.json")


if __name__ == "__main__":
    main()
