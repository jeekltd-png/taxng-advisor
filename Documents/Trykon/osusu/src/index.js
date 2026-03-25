const { Member, OsusuGroup } = require('./osusu');

console.log('osusu Node.js app started');

const group = new OsusuGroup('Bootstrap Savings');
const alice = new Member('Alice');
const bob = new Member('Bob');

alice.deposit(200);
bob.deposit(150);

group.addMember(alice);
group.addMember(bob);

console.log(`${group.name} total balance: ${group.totalBalance}`);
