from .helpful_scripts import get_account
from .deploy import deploy_token

def mint_and_airdrop_local():
    account = get_account()
    ottoman_token = deploy_token()
    print("Token has deployed!")
    start_mint_tx = ottoman_token.startMinting({"from": account})
    start_mint_tx.wait(1)
    print("Minting started!")
    for i in range(1,6):
        minter = get_account(index=i)
        mint_tx = ottoman_token.mintToken(50 , {"from": minter, "value": 0.0004})
        mint_tx.wait(1)
        print(f"50 tokens was minted by {minter}")
    end_mint_tx = ottoman_token.endMinting({"from": account})
    end_mint_tx.wait(1)
    print("Minting is over.")
    airdrop = ottoman_token.isAirdrop()
    print(airdrop)
    withdraw_tx = ottoman_token.withdrawFunds({"from": account})
    withdraw_tx.wait(1)
    print("Withdraw is successfully!")

def main():
    mint_and_airdrop_local()