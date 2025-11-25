// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

contract CryptoBank {

    // 1. Custom Errors: Save gas compared to string messages in 'require'
    error NotAuthorized();
    error MaxBalanceReached();
    error InsufficientBalance();
    error TransferFailed();
    error InvalidAddress();

    uint256 public maxBalance;
    address public admin;
    mapping(address => uint256) public userBalance;

    // 2. Indexed Parameters: Allows efficient event filtering from the frontend
    event EtherDeposit(address indexed _user, uint256 _etherAmount);
    event EtherWithdraw(address indexed _user, uint256 _etherAmount);
    event MaxBalanceChanged(uint256 _newMaxBalance);

    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert NotAuthorized();
        }
        _;
    }

    constructor(uint256 _maxBalance, address _admin) {
        // 3. Basic security check: Ensure admin is not the zero address
        if (_admin == address(0)) revert InvalidAddress();
        
        maxBalance = _maxBalance;
        admin = _admin;
    }

    function depositEther() external payable {
        // Verification using Custom Error for gas efficiency
        if (userBalance[msg.sender] + msg.value > maxBalance) {
            revert MaxBalanceReached();
        }

        userBalance[msg.sender] += msg.value;
        emit EtherDeposit(msg.sender, msg.value);
    }

    function withdrawEther(uint256 _amount) external {
        if (_amount > userBalance[msg.sender]) {
            revert InsufficientBalance();
        }

        // 4. Checks-Effects-Interactions Pattern (CEI) to prevent re-entrancy attacks
        // Effect: Update state variables first
        userBalance[msg.sender] -= _amount;

        // Interaction: Perform external calls/transfers last
        (bool success, ) = msg.sender.call{value: _amount}("");
        
        if (!success) {
            revert TransferFailed();
        }

        emit EtherWithdraw(msg.sender, _amount);
    }

    function modifyMaxBalance(uint256 _newMaxBalance) external onlyAdmin {
        maxBalance = _newMaxBalance;
        // It is best practice to emit an event when critical parameters change
        emit MaxBalanceChanged(_newMaxBalance);
    }
}