# Setting up Two GitHub Identities on the Same Mac — Step-by-Step Guide

> **Goal**: Use separate **SSH keys** and **Git identities** for  
> 1) work → corporate GitHub    
> 2) personal → private GitHub  
> Ensuring they never **cross paths**.

---

## Prerequisites

* macOS with Git ≥ 2.13 and OpenSSH ≥ 7.5  
* Access to both GitHub accounts (work & personal)  
* Home directory structured like this (you can change paths, but be consistent):
  ```
  ~/code/work/…      # corporate repos
  ~/code/personal/…  # personal repos
  ```

---

## 1 · Generate (or import) two SSH keys

```bash
# Personal key
ssh-keygen -t ed25519 -C "emptylime@proton.me" -f ~/.ssh/id_ed25519_personal

# Work key
ssh-keygen -t ed25519 -C "[email protected]" -f ~/.ssh/id_ed25519_work
```

> **macOS Tip**  
> Save the pass-phrase in the keychain (no prompt on every push):
> ```bash
> ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
> ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
> ```

* Upload the **`.pub`** files to the respective GitHub _SSH Keys_ sections.

---

## 2 · Configure `~/.ssh/config`

```sshconfig
Host *                         # default rules
    AddKeysToAgent yes
    UseKeychain   yes

# === Personal Identity =======================
Host github.com-personal
    HostName      github.com
    User          git
    IdentityFile  ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes       # force *only* this key

# === Work Identity ==========================
Host github.com-work
    HostName      github.com
    User          git
    IdentityFile  ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

*The aliases `github.com-personal` and `github.com-work` replace the real host
in the remote URL.*

---

## 3 · Set up Git identities

### 3.1 Default **personal** identity

```bash
git config --global user.name  "John Doe"
git config --global user.email "[email protected]"
```

### 3.2 **Work** identity only under `~/code/work/`

1. Create `~/.gitconfig-work`:

   ```ini
   [user]
       name  = John Doe (ACME)
       email = [email protected]
   ```

2. Add to `~/.gitconfig` (after global settings):

   ```ini
   [includeIf "gitdir:~/code/work/"]
       path = ~/.gitconfig-work
   ```

> `includeIf` changes user/email **only** for repos that live in that path.

---

## 4 · Clone (or reconfigure) repositories

```bash
# Personal repo
git clone git@github.com-personal:YourUser/my-hobby-repo.git           ~/code/personal/my-hobby-repo

# Work repo
git clone git@github.com-work:WorkOrg/infra.git           ~/code/work/infra
```

Already existing repos?  
```bash
cd /path/to/repo
git remote set-url origin git@github.com-work:WorkOrg/infra.git
```

---

## 5 · Error prevention verification

```bash
# 1. Check key/host:
ssh -T github.com-work      # should respond with "Hi WorkUser!"

# 2. Inside a repo:
git config user.name && git config user.email  # correct?
git remote -v                                # correct host alias?
git push --dry-run                           # test without risks
```

If you used the wrong host or directory, GitHub responds with "Permission denied (publickey)".

---

## 6 · "One-shot" commands (optional)

*To force a key only for that command:*

```bash
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_work" git pull
```

Or, for a single repo:

```bash
git config core.sshCommand   "ssh -i ~/.ssh/id_ed25519_work -F /dev/null"
```

---

## 7 · Common mistakes to avoid

| ❌  | Reason |
|-----|--------|
| Using `ssh-add -K` *without* `IdentitiesOnly yes` | macOS presents **all** keys → GitHub takes the first one and fails |
| Cloning with `git@github.com:…` and expecting the alias to work | OpenSSH uses the literal host: must be `github.com-work` or `github.com-personal` |
| Mixing work/personal repos in the same folder | `includeIf` doesn't trigger → wrong email on commit! |

---

## 8 · Final checklist

- [ ] Two keys generated and uploaded to GitHub.
- [ ] Aliases configured in `~/.ssh/config`.
- [ ] Remotes with host aliases (`github.com-work` / `github.com-personal`).
- [ ] `includeIf` file active to separate Git identities.
- [ ] `ssh -T`, `git push --dry-run` tests ok.

---

**Done!** Now you can switch between _work_ and _personal_ projects without risk
of pushing or committing with the wrong identity.  
Happy coding! 🛠️
