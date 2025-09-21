# Pull Request

## 📄 Summary

> Clearly describe what this PR changes and why it is necessary.  
> Link to any relevant issue(s) below.

---

## 🧩 Affected Module(s)

Mark the modules impacted by this PR:

- [ ] Source Code
- [ ] Documentation
- [ ] CI / Infra

---

## ✏️ PR Title Format

> ⚠️ PR title must follow [Conventional Commits](https://www.conventionalcommits.org/) format.  
> **Only these types are allowed:**

```text
feat, fix, chore, refactor, test, docs, ci, perf, build, release, hotfix, style
```

✅ Examples:

```text
feat: add lifecycle state validator for widgets
fix: resolve webhook retry issue in network layer
chore: clean up unused Flutter plugins and dependencies
refactor: simplify event dispatcher with ChangeNotifier
test: add integration test for HexaCast widget
docs: update contributing guide with Flutter setup
ci: improve GitHub Actions caching for pub packages
perf: reduce widget rebuild latency in trigger handling
build: update pubspec.lock and bump package versions
release: prepare v0.3.0 Flutter app release
hotfix: patch crash on runtime navigation
style: apply dart format to all Dart files

```

---

## ✅ Checklist

Before submitting, make sure you've completed the following:

- [ ] My branch name follows format: `<type>/<short-description>` (e.g., `feat/auth-handler`)
- [ ] My PR title starts with one of the approved types listed above
- [ ] My code passes formatting (`dart format .`)
- [ ] I ran Clippy linter (`flutter analyze`) and resolved warnings
- [ ] I ran tests successfully (`flutter test`)
- [ ] I linked related issues using keywords like `Closes #42`
- [ ] I ensured this PR has no unrelated changes
- [ ] This PR is ready for review and does not include unfinished work

---

## 🔗 Related Issues

> If this PR addresses one or more issues, link them here:

```text
Closes #
```

---

## 💬 Additional Notes (Optional)

> Include any test instructions, screenshots, diagrams, or context useful for reviewers.
