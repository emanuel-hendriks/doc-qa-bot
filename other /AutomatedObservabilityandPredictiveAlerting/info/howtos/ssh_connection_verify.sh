# Check Git user config:
git config user.name
git config user.email

# Test SSH connection:
ssh -T git@github.com-personal
ssh -T git@github.com

# Check which SSH key is being used:
ssh -vT git@github.com-personal
ssh -vT git@github.com

# Check SSH config:
cat ~/.ssh/config

# Check SSH keys:
ls ~/.ssh

# Check SSH key permissions:
ls -l ~/.ssh

# Check SSH key fingerprints:
ssh-keygen -l -f ~/.ssh/id_ed25519_personal
ssh-keygen -l -f ~/.ssh/id_ed25519_work


