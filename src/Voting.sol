// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;

    mapping(address => bool) public hasVoted;

    constructor(string[] memory candidateNames) {
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(
                Candidate({
                    name: candidateNames[i],
                    voteCount: 0
                })
            );
        }
    }

    function vote(uint256 candidateIndex) public {
        require(!hasVoted[msg.sender], "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[candidateIndex].voteCount++;
    }

    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function getWinner() public view returns (string memory winnerName) {
        require(candidates.length > 0, "No candidates");

        uint256 winningIndex = 0;

        for (uint256 i = 1; i < candidates.length; i++) {
            if (
                candidates[i].voteCount >
                candidates[winningIndex].voteCount
            ) {
                winningIndex = i;
            }
        }

        winnerName = candidates[winningIndex].name;
    }
}