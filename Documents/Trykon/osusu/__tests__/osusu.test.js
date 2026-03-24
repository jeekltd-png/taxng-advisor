const { Member, OsusuGroup } = require('../src/osusu');

test('member deposit and withdraw behavior', () => {
  const member = new Member('Tester');
  member.deposit(100);
  expect(member.balance).toBe(100);
  member.withdraw(40);
  expect(member.balance).toBe(60);
});

test('osusu group balance sums members', () => {
  const group = new OsusuGroup('Test Group');
  const memberA = new Member('A');
  const memberB = new Member('B');

  memberA.deposit(50);
  memberB.deposit(75);

  group.addMember(memberA);
  group.addMember(memberB);

  expect(group.totalBalance).toBe(125);
});
