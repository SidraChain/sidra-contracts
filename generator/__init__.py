from .genesis import GenesisGenerator
from .contract import Contract

OWNER_ADDRESS = "0x3efEba5D4B05b947df4A95D24C6671baDaAD1fc9"
SUPER_OWNER_ADDRESS = "0x3efEba5D4B05b947df4A95D24C6671baDaAD1fc9"

MINER_ADDRESS = "0x3efEba5D4B05b947df4A95D24C6671baDaAD1fc9"
MINER_BALANCE = 100

OWNER_CONTRACT = Contract(
    "Owner",
    "0x0000000000000000000000000000000000000010"
)
WAC_CONTRACT = Contract(
    "WalletAccessControl",
    "0x0000000000000000000000000000000000000020"
)
SIDRA_TOKEN_CONTRACT = Contract(
    "SidraToken",
    "0x0000000000000000000000000000000000000030"
)
MAIN_FAUCET_CONTRACT = Contract(
    "MainFaucet",
    "0x0000000000000000000000000000000000000040"
)
WAQF_CONTRACT = Contract(
    "Waqf",
    "0x0000000000000000000000000000000000000050"
)
ZAKAT_CONTRACT = Contract(
    "Zakat",
    "0x0000000000000000000000000000000000000060"
)


def generate_genesis():
    genesis = GenesisGenerator(MINER_ADDRESS, miner_balance=MINER_BALANCE)

    # TODO: Add SuperOwner Owner and Miner

    # Add contracts
    OWNER_CONTRACT.set_value("owner", OWNER_ADDRESS)
    OWNER_CONTRACT.set_value("superOwner", SUPER_OWNER_ADDRESS)
    genesis.add_contract(OWNER_CONTRACT)

    WAC_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    # Mark OWNER_ADDRESS as as whitelisted
    WAC_CONTRACT.set_mapping_value("status", OWNER_ADDRESS, 1)
    WAC_CONTRACT.set_mapping_value("status", MINER_ADDRESS, 1)
    WAC_CONTRACT.set_mapping_value("status", SUPER_OWNER_ADDRESS, 1)
    WAC_CONTRACT.set_value("whitelistCount", 3)
    genesis.add_contract(WAC_CONTRACT)

    SIDRA_TOKEN_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    SIDRA_TOKEN_CONTRACT.set_value("wac", WAC_CONTRACT.address)
    genesis.add_contract(SIDRA_TOKEN_CONTRACT)

    MAIN_FAUCET_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(MAIN_FAUCET_CONTRACT)

    WAQF_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(WAQF_CONTRACT)

    ZAKAT_CONTRACT.set_value("owner", OWNER_CONTRACT.address)
    genesis.add_contract(ZAKAT_CONTRACT)

    genesis.save("genesis.json")
