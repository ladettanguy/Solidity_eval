// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;
 

contract Marketplace {

    event ProductAdded(uint256 id, string name, uint256 cost, address seller);
    event ProductBought(uint256 id, string name, uint256 cost, address seller, address buyer);

    uint256 private id_counteur = 0;
    struct Product {
        uint256 id;
        string name;
        uint256 cost;
        bool selled;
        address seller;
    }

    function createProduct(string calldata name, uint256 cost, address seller) private returns (Product memory)
    {
        Product memory p = Product(id_counteur, name, cost, false, seller);
        id_counteur += 1;
        return p;
    }

    Product[] public products;
    mapping(address=>uint256) public balance;
    mapping(uint256=>Product) private id_produit_map;

    function sellProduct(string calldata name, uint256 cost) public {
        Product memory product = createProduct(name, cost, msg.sender);
        id_produit_map[product.id] = product;
        products.push(product);
        emit ProductAdded(product.id, product.name, product.cost, product.seller);
    }

    function buyProduct(uint id_product) public returns (bool){
        Product memory product = id_produit_map[id_product];
        if (product.cost < balance[msg.sender]) 
        { 
            _removeBalanceFromAddress(msg.sender, product.cost);
            _addBalanceFromAddress(product.seller, product.cost);

            emit ProductBought(product.id, product.name, product.cost, product.seller, msg.sender);

            product.selled = true;
            delete id_produit_map[product.id];
            return true;
        }
        else {
            return false;
        }
    }

    function getBalance() public view returns(uint256){
        return balance[msg.sender];
    }

    function addBalance() public payable {
        _addBalanceFromAddress(msg.sender, msg.value);
    }

    function _removeBalanceFromAddress(address addr, uint256 amount) private
    {
        require(balance[addr] > amount, "Not enough");
        balance[addr] -= amount;
    }

    function _addBalanceFromAddress(address addr, uint256 amount) private {
        balance[addr] += amount;
    }

}
