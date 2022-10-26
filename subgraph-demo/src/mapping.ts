import { BigInt } from "@graphprotocol/graph-ts"
import { Transfer } from "../generated/KlaySwapProtocol/IERC20"
import { Account, Balance, Transfer as TransferEntity } from "../generated/schema"

function createAccount(address: string): void {
  let account = Account.load(address);
  if (!account) {
    account = new Account(address);
    account.save();
  }
}

export function handleTransfer(event: Transfer): void {
  createAccount(event.params.to.toHex());
  let id = event.params.to.toHex().concat(event.address.toHex());
  let balance = Balance.load(id);
  if (!balance) {
    balance = new Balance(id);
    balance.token = event.address;
    balance.account = event.params.to.toHex();
    balance.amount = BigInt.zero();
  }
  balance.amount = balance.amount.plus(event.params.value);
  balance.save();

  createAccount(event.params.from.toHex());
  id = event.params.from.toHex().concat(event.address.toHex());
  balance = Balance.load(id);
  if (!balance) {
    balance = new Balance(id);
    balance.token = event.address;
    balance.account = event.params.from.toHex();
    balance.amount = BigInt.zero();
  }
  balance.amount = balance.amount.minus(event.params.value);
  balance.save();

  // do not have to load `Transfer` entity as it is unique each time
  id = event.block.number.toString().concat(event.logIndex.toString());
  let transfer = new TransferEntity(id);
  transfer.token = event.address;
  transfer.from = event.params.from.toHex();
  transfer.to = event.params.to.toHex();
  transfer.value = event.params.value;
  transfer.transaction = event.transaction.hash;
  transfer.block = event.block.number;
  transfer.save();
}