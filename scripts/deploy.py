from brownie import OttomanToken, config, network

from .helpful_scripts import get_account, get_contract


def deploy_token():
    account = get_account()
    ottoman_token = OttomanToken.deploy(
        1000000,
        get_contract("eth_usd_price_feed").address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    print(f"The token contract deployed at {ottoman_token.address}")
    return ottoman_token


def main():
    deploy_token()
