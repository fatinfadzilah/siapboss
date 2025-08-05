import bcrypt from 'bcryptjs';

async function hashPassword() {
  const password = 'staff123';
  const hashed: string = await bcrypt.hash(password, 10);
  console.log('Hashed password:', hashed);
}

hashPassword();
