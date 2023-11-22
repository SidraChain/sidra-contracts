from .genesis import GenesisGenerator
from .contract import Contract

OWNER_ADDRESS = "0xEB70231e39A0282974B8CFB37F63FcD795F3beFb"
SUPER_OWNER_ADDRESS = "0xEB70231e39A0282974B8CFB37F63FcD795F3beFb"

MINER_ADDRESS = "0x3efEba5D4B05b947df4A95D24C6671baDaAD1fc9"
MINER_BALANCE = 100

OWNER_CONTRACT = Contract(
    name="Owner",
    address="0x0000000000000000000000000000000000000010"
)
WAC_CONTRACT = Contract(
    name="WalletAccessControl",
    address="0x0000000000000000000000000000000000000020"
)
PAC_CONTRACT = Contract(
    name="PoolAccessControl",
    address="0x0000000000000000000000000000000000000030"
)
SIDRA_TOKEN_CONTRACT = Contract(
    name="SidraToken",
    address="0x0000000000000000000000000000000000000040",
    balance='max'
)
MAIN_FAUCET_CONTRACT = Contract(
    name="MainFaucet",
    address="0x0000000000000000000000000000000000000050",
    balance=10_000_000  # 10M
)
WAQF_CONTRACT = Contract(
    name="Waqf",
    address="0x0000000000000000000000000000000000000060"
)
ZAKAT_CONTRACT = Contract(
    "Zakat",
    "0x0000000000000000000000000000000000000070"
)


def generate_genesis():
    genesis = GenesisGenerator(MINER_ADDRESS, miner_balance=MINER_BALANCE)

    # TODO: Add SuperOwner Owner and Miner
    genesis.add_account(OWNER_ADDRESS, 100)

    # Add contracts
    OWNER_CONTRACT.set_value("owner", OWNER_ADDRESS)
    OWNER_CONTRACT.set_value("superOwner", SUPER_OWNER_ADDRESS)
    genesis.add_contract(OWNER_CONTRACT)

    WAC_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    # Mark OWNER_ADDRESS as as whitelisted
    WAC_CONTRACT.set_mapping_value("status", OWNER_ADDRESS, 1)
    WAC_CONTRACT.set_mapping_value("status", MINER_ADDRESS, 1)
    WAC_CONTRACT.set_mapping_value("status", SUPER_OWNER_ADDRESS, 1)
    WAC_CONTRACT.set_value("whitelistCount", 2)
    genesis.add_contract(WAC_CONTRACT)

    PAC_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(PAC_CONTRACT)

    SIDRA_TOKEN_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    SIDRA_TOKEN_CONTRACT.set_value("wac", WAC_CONTRACT.address)
    SIDRA_TOKEN_CONTRACT.set_value("faucet", MAIN_FAUCET_CONTRACT.address)
    genesis.add_contract(SIDRA_TOKEN_CONTRACT)

    MAIN_FAUCET_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(MAIN_FAUCET_CONTRACT)

    WAQF_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(WAQF_CONTRACT)

    ZAKAT_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(ZAKAT_CONTRACT)

    genesis.save("genesis.json")
