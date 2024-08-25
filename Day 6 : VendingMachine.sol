// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import “@openzeppelin/contracts/access/Ownable.sol”;
import “@openzeppelin/contracts/access/AccessControl.sol”;

contract AdvancedVendingMachine is Ownable, AccessControl {
bytes32 public constant MANAGER_ROLE = keccak256(“MANAGER_ROLE”);

struct Item {
string name;
uint price;
uint stock;
uint purchaseLimit;
}

mapping(uint => Item) public items; // Item ID to Item
mapping(address => mapping(uint => uint)) public userPurchases; // User to Item ID to quantity purchased
uint public itemCount;

bool public contractPaused = false;

event ItemPurchased(address indexed buyer, uint indexed itemId, uint quantity, uint amountPaid);
event ItemRestocked(uint indexed itemId, uint quantity);
event ContractPaused();
event ContractResumed();

modifier onlyManager() {
require(hasRole(MANAGER_ROLE, msg.sender), “Only manager can perform this action”);
_;
}

modifier whenNotPaused() {
require(!contractPaused, “Contract is paused”);
_;
}

constructor() {
_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
_setupRole(MANAGER_ROLE, msg.sender);
}

// Function to add a new item
function addItem(string memory name, uint price, uint stock, uint purchaseLimit) public onlyManager {
items[itemCount] = Item(name, price, stock, purchaseLimit);
itemCount++;
}

// Function to update item details
function updateItem(uint itemId, string memory name, uint price, uint stock, uint purchaseLimit) public onlyManager {
require(itemId < itemCount, “Invalid item ID”);
items[itemId] = Item(name, price, stock, purchaseLimit);
}

// Function to restock an item
function restockItem(uint itemId, uint quantity) public onlyManager {
require(itemId < itemCount, “Invalid item ID”);
items[itemId].stock += quantity;
emit ItemRestocked(itemId, quantity);
}

// Function to purchase an item
function purchaseItem(uint itemId, uint quantity) public payable whenNotPaused {
require(itemId < itemCount, “Invalid item ID”);
Item memory item = items[itemId];
require(item.stock >= quantity, “Not enough stock available”);
require(msg.value >= item.price * quantity, “Not enough Ether provided”);
require(userPurchases[msg.sender][itemId] + quantity <= item.purchaseLimit, “Purchase limit exceeded”);

items[itemId].stock -= quantity;
userPurchases[msg.sender][itemId] += quantity;

// Send excess Ether back to the buyer
if (msg.value > item.price * quantity) {
payable(msg.sender).transfer(msg.value — item.price * quantity);
}

emit ItemPurchased(msg.sender, itemId, quantity, msg.value);
}

// Function to pause the contract
function pauseContract() public onlyOwner {
contractPaused = true;
emit ContractPaused();
}

// Function to resume the contract
function resumeContract() public onlyOwner {
contractPaused = false;
emit ContractResumed();
}

// Function to withdraw Ether from the contract
function withdraw() public onlyOwner {
payable(owner()).transfer(address(this).balance);
}
}
