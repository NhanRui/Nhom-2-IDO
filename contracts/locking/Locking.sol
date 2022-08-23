// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ILockedAmount.sol";

uint256 constant DEFAULT_LOCKED_TIME = 4 minutes; // testing

contract Locking is ILockedAmount, Ownable {
    IERC20 public token;
    uint256 private _lockedTime = DEFAULT_LOCKED_TIME;

    mapping(address => uint256) public _lockedAmount;
    mapping(address => uint256) public _lockedUntil;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
    }

    function tokenAddress() public view returns (address) {
        return address(token);
    }

    function locked(address owner)
        external
        view
        returns (uint256 quantity, uint256 lockedUntil)
    {
        return (_lockedAmount[owner], _lockedUntil[owner]);
    }

    function claimVesting(uint256 id, uint256 index) external {
        Vesting storage vesting = _vesting[id][index];
        IDO storage ido = getId(id);
        require(!vesting.claimed, "Already claimed");
        require(vesting.timestamp >= block.timestamp);
        require(ido.owner == msg.sender, "Not IDO Owner");
        ido.params.token.mint(vesting.beneficiary, vesting.amount);
        vesting.claimed = true;
    }

    function lockedAmount(address owner)
        external
        view
        override
        returns (uint256 quantityl)
    {
        return _lockedAmount[owner];
    }

    function lock(uint256 amount) public {
        token.transferFrom(msg.sender, address(this), amount);
        _lockedAmount[msg.sender] += amount;
        _lockedUntil[msg.sender] = block.timestamp + _lockedTime;
        emit Deposit(msg.sender, amount);
    }

    function unlock(uint256 amount) public {
        require(_lockedAmount[msg.sender] >= amount, "Not enough stack");
        require(_lockedUntil[msg.sender] <= block.timestamp, "Too early");
        token.transfer(msg.sender, amount);
        _lockedAmount[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);
    }

    /**
     * @dev Withdraws the amount, Fails on unsuccessful tx.
     */
    function withdraw(uint256 id, uint256 amount) public {
        IDO storage ido = getId(id);
        require(bought[id][msg.sender] >= amount, "Not enough bought");
        bought[id][msg.sender] -= amount;
        ido.params.totalBought -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(id, msg.sender, amount, ido.params.totalBought);
    }
    
    function setLockTime(uint256 amount) public onlyOwner {
        _lockedTime = amount;
    }
}
