# How to Determine Which Git and SSH Credentials Are Used on macOS

This guide explains how to verify which Git user identity and SSH key are being used for a given repository or GitHub operation on macOS. This is especially useful when managing multiple GitHub accounts (e.g., work and personal).

---

## 1. Check the Active Git User Identity

Run the following commands inside your repository:

```bash
git config user.name
git config user.email
```

- If these are blank, Git will fall back to your global configuration (`git config --global ...`).
- If you use `includeIf` in your `~/.gitconfig`, the output will reflect the identity for the current directory.

---

## 2. Check the Remote URL and Host Alias

```bash
git remote -v
```

- Look for `github.com-work` or `github.com-personal` in the remote URL. This tells you which SSH config alias will be used.

---

## 3. See Which SSH Key Is Used for GitHub

To test which SSH key is used for a given host alias:

```bash
ssh -vT github.com-work
ssh -vT github.com-personal
```

- The `-vT` flags show verbose output and test authentication.
- Look for lines like `Offering public key: ...` and `Authentication succeeded`.
- The path to the key (e.g., `~/.ssh/id_ed25519_work`) will be shown in the output.

---

## 4. Check SSH Agent and Loaded Keys

```bash
ssh-add -l
```

- Lists all keys currently loaded in your SSH agent.
- If your key is not listed, add it with:
  ```bash
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
  ```

---

## 5. Inspect SSH Config

```bash
cat ~/.ssh/config
```

- Review which `Host` aliases point to which keys.
- Ensure `IdentitiesOnly yes` is set to force the use of the specified key.

---

## 6. Test a Push Without Making Changes

```bash
git push --dry-run
```

- This will attempt to authenticate and show if you have push access, without changing anything.

---

## 7. Troubleshooting

- If you see `Permission denied (publickey)`, your SSH key is not recognized by GitHub for that account.
- Double-check your remote URL, SSH config, and which key is loaded.

---

## Summary Table

| What to Check                | Command Example                        |
|-----------------------------|----------------------------------------|
| Git user/email              | `git config user.name` / `user.email`  |
| Remote host alias           | `git remote -v`                        |
| SSH key used (verbose)      | `ssh -vT github.com-work`              |
| Loaded SSH keys             | `ssh-add -l`                           |
| SSH config                  | `cat ~/.ssh/config`                    |
| Test push                   | `git push --dry-run`                   |

---

By following these steps, you can always determine which credentials (Git identity and SSH key) are being used for any GitHub operation on your Mac.
