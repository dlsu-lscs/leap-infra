## Generate a Personal Access Token

1. **Log in to GitHub** and go to your profile settings (click your profile picture in the top right → Settings)

2. **Navigate to Developer Settings**:
   - Scroll down to the bottom of the sidebar
   - Click on "Developer settings"

3. **Access Personal Access Tokens**:
   - Click on "Personal access tokens"
   - Click on "Fine-grained tokens" (preferred for better security) or "Tokens (classic)"
   - Click "Generate new token"

4. **Configure the token**:

   **For Fine-grained tokens (recommended):**
   - Token name: `leap25-backend-repo-access`
   - Expiration: Choose an appropriate expiration date (recommend 90 days or less)
   - Repository access: Select "Only select repositories"
   - Select the repository: `dlsu-lscs/leap-infra` (the repo you're triggering workflows in)
   - Permissions:
     - Under "Repository permissions":
       - "Contents": Read & Write 
       - "Metadata": Read-only
       - "Actions": Read & Write (to trigger workflows)

   **For Classic tokens:**
   - Note: `leap25-backend-repo-access`
   - Expiration: Choose an appropriate date
   - Select scopes:
     - `repo` (Full control of private repositories)
     - `workflow` (Workflow control)

5. **Click "Generate token"** at the bottom

6. **Copy the token immediately** as it won't be shown again

## Add the Token to Repository Secrets

1. Go to your `leap25-backend` repository
2. Click on "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Name: `REPO_ACCESS_TOKEN`
5. Value: Paste the token you copied
6. Click "Add secret"

## Verify the Workflow

In your `.github/workflows/build-push-deploy.yml` file, you're using this token:

```yaml
- name: Trigger deployment workflow
  uses: peter-evans/repository-dispatch@v2
  with:
    token: ${{ secrets.REPO_ACCESS_TOKEN }}
    repository: dlsu-lscs/leap-infra
    event-type: backend-update
    client-payload: |
      {
        "image": "${{ needs.build-and-push.outputs.image }}",
        "has_migrations": ${{ needs.build-and-push.outputs.has_migrations }},
        "branch": "${{ needs.build-and-push.outputs.branch }}",
        "commit_sha": "${{ needs.build-and-push.outputs.commit_sha }}"
      }
```

This workflow uses the token to trigger a workflow in another repository (`dlsu-lscs/leap-infra`).

## Security Considerations

1. **Limit permissions**: Use fine-grained tokens whenever possible
2. **Set reasonable expiration**: Avoid tokens that never expire
3. **Token rotation**: Replace tokens periodically
4. **Audit access**: Regularly review who has access to these tokens
