// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract TaxedToken is ERC20, Ownable(msg.sender) {
    uint256 public buyTax = 3;  // 3%
    uint256 public sellTax = 5; // 5%
    uint256 public transferTax = 1; // 1%
    address public feeRecipient;

    mapping (address => bool) public isTaxExempt;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _feeRecipient
    ) ERC20(name, symbol) {
        feeRecipient = _feeRecipient;
        _mint(msg.sender, initialSupply);
        isTaxExempt[msg.sender] = true; // Owner is tax-exempt
        isTaxExempt[feeRecipient] = true;
    }
    
    // Allows the owner to set the fee recipient
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    // Allows the owner to set new tax rates
    function setTaxRates(uint256 _buyTax, uint256 _sellTax, uint256 _transferTax) external onlyOwner {
        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
    }

    

    // Override _transfer to apply tax logic
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender!=address(0),"Invalid sender");
        require(recipient!=address(0),"Invalid receiver");

        if (isTaxExempt[sender] || isTaxExempt[recipient]) {
            super._transfer(sender, recipient, amount); // Transfer without tax
        } else {
            uint256 taxAmount = 0;

            // Apply tax based on whether it's a buy, sell, or transfer
            if (isBuy(sender)) {
                taxAmount = (amount * buyTax) / 100;
            } else if (isSell(recipient)) {
                taxAmount = (amount * sellTax) / 100;
            } else {
                taxAmount = (amount * transferTax) / 100;
            }

            uint256 amountAfterTax = amount - taxAmount;
            super._transfer(sender, recipient, amountAfterTax); // Transfer the remaining amount
            super._transfer(sender, feeRecipient, taxAmount);   // Transfer the tax to feeRecipient
        }
    }

    // Placeholder function to determine if it's a buy transaction
    function isBuy(address sender) internal view returns (bool) {
        // Add your logic to determine if it's a buy transaction
        return false; // This is a placeholder
    }

    // Placeholder function to determine if it's a sell transaction
    function isSell(address recipient) internal view returns (bool) {
        // Add your logic to determine if it's a sell transaction
        return false; // This is a placeholder
    }
}
