from brownie import OttomanToken
from .deploy import deploy_token
from .helpful_scripts import get_account


def start_minting():
    account = get_account()
    ottoman_token = deploy_token()
    print("Token has deployed!")
    start_mint_tx = ottoman_token.startMinting({"from": account})
    start_mint_tx.wait(1)
    print("Minting started!")


def mint(name, amount):
    ottoman_token = OttomanToken[-1]
    account = get_account(name=name)
    mint_tx = ottoman_token.mintToken(
        amount, {"from": account, "value": (get_eth_price(amount))}
    )
    mint_tx.wait(1)
    print(f"{amount} tokens was minted by {account}")


def get_eth_price(amount):
    return (((amount / 100) / 1600) + 0.001) * 10**18


def end_minting():
    account = get_account()
    ottoman_token = OttomanToken[-1]
    end_mint_tx = ottoman_token.endMinting({"from": account})
    end_mint_tx.wait(1)
    print("Minting is over.")
    if ottoman_token.isAirdrop() == True:
        print("The airdrop was successfully carried out.")
    else:
        print("There is no airdrop.")


def withdraw_funds():
    account = get_account()
    ottoman_token = OttomanToken[-1]
    witdraw_tx = ottoman_token.withdrawFunds({"from": account})
    witdraw_tx.wait(1)
    print(f"Funds were withdrew by {account} successfully!")


def main():
    start_minting()
    mint("from_key_test_1", 3000)
    mint("from_key_test_2", 4500)
    mint("from_key_test_3", 10000)
    mint("from_key_test_4", 8000)
    mint("from_key_test_5", 6500)
    end_minting()
    withdraw_funds()
