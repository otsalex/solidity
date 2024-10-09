// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

contract Lottery {

    address[] public players;
    uint256 lastDistribution;
    
    function enter()
        public
        payable {
            require(msg.value == 1 ether, "ticket costs 1 ether");
            players.push(msg.sender);
            
    }

    function viewBalance()
        public
        view
        returns (uint256) {
            return address(this).balance;
    }

    function pickWinner()
        public {
            // 1. check the lastDistribution
            uint256 hour = 60 * 60;
            uint256 timeFromLastDistribution = block.timestamp - lastDistribution;
            require(timeFromLastDistribution > hour, "Hour has not passed since the last distribution");

            // 2. randmoly (pseudo) select the winner
            uint256 random = getPseudoRandomNumber(players.length);
            
            // 3. make the payment
            address winner = players[random];
            uint256 pool = address(this).balance;
            (bool ok, ) = winner.call{value: pool}("");
            require(ok, "Transferring to winner failed");

            // 4. clear players
            delete players;

            // 5. set the lastDistribution
            lastDistribution = block.timestamp;
        }

    function getPseudoRandomNumber(uint256 max) 
        internal 
        view 
        returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        ) % max;
    }
}