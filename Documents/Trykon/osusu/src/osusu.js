class Member {
  constructor(name) {
    if (!name) throw new Error('Member name is required');
    this.name = name;
    this.balance = 0;
  }

  deposit(amount) {
    if (amount <= 0) throw new Error('Deposit amount must be positive');
    this.balance += amount;
  }

  withdraw(amount) {
    if (amount <= 0) throw new Error('Withdraw amount must be positive');
    if (amount > this.balance) throw new Error('Insufficient balance');
    this.balance -= amount;
  }
}

class OsusuGroup {
  constructor(name, options = {}) {
    if (!name) throw new Error('Group name is required');
    this.name = name;
    this.members = [];
    this.currency = options.currency || 'GBP';
    this.locale = options.locale || 'en-GB';
    this.country = options.country || 'UK';
    this.contributionAmount = Number(options.contributionAmount || 100);
    this.cycleType = options.cycleType || 'weekly';
  }

  addMember(member) {
    if (!(member instanceof Member)) throw new Error('member must be a Member');
    this.members.push(member);
  }

  get totalBalance() {
    return this.members.reduce((sum, m) => sum + m.balance, 0);
  }
}

module.exports = { Member, OsusuGroup };
