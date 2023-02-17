
pragma solidity ^0.8.0;

import "../../solidity/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ApprovedOperatableERC721 is ERC721 {
    //uint private _expire;

    //定义一个管理员地址映射；
    mapping(address => bool) private _adminAddresses;
    //定义一个特权地址映射；
    mapping(address => bool) private _privilegeAddresses;
    //定义一个永不过期的映射；
    mapping(uint256 => uint) private _tokenDeadline;


    //构造函数；
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _adminAddresses[msg.sender] = true;
    }

    //覆盖ERC721的_beforeTokenTransfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        if (from != address(0)) {/*转移和销毁判断*/
            if (_privilegeAddresses[msg.sender] == false/*操作员不是特权账户*/ && _adminAddresses[msg.sender] == false/*操作员不是管理账户*/ && (block.timestamp < _tokenDeadline[firstTokenId]/*未到期*/ || _tokenDeadline[firstTokenId] == 0)/*永久*/) {
                revert("failed");

            }

        }

    }

    //定义一个调用ERC721的mint方法，并可以自定义参数，需要调用_mint方法，在新建一个contract limitmint；
    function _limitmint(address to, uint256 tokenId, uint expire) public {
        _mint(to, tokenId);
        _tokenDeadline[tokenId] = expire;
    }

    //定义一个添加管理员地址的方法；
    function addAdminAddress(address adminAddress) public {
        require(_adminAddresses[msg.sender], "Need AdminAddress!");
        _adminAddresses[adminAddress] = true;

    }

    //定义一个删除管理员地址的方法；
    function delAdminAddress(address adminAddress) public {
        require(_adminAddresses[msg.sender], "Need AdminAddress!");
        delete _adminAddresses[adminAddress];

    }

    //定义一个添加特权地址的方法；
    function addPrivilegeAddress(address privilegeAddress) public {
        require(_adminAddresses[msg.sender], "Need AdminAddress!");
        _privilegeAddresses[privilegeAddress] = true;

    }

    //定义一个删除特权地址的方法；
    function delPrivilegeAddress(address privilegeAddress) public {
        require(_adminAddresses[msg.sender], "Need AdminAddress!");
        delete _privilegeAddresses[privilegeAddress];
    }


}
