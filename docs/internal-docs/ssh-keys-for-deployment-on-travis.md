---
layout: default
---

## Encrypted SSH deployment keys on travis

This will show you how to create ssh deployment keys and encrypt them for use in travis.

### Preparation

```
brew install ruby
sudo gem install travis
travis login
```

### Generate a key

Replace repo with your service name. We do this on a per-service basis so we can easily revoke if compromised.

```
export REPO=<name of repo>
ssh-keygen -t rsa -b 4096 -N "" -C ${REPO}@travis-ci.org -f ./${REPO}_deploy_rsa
```

### Encrypyt key

First, cd to the directory with the `.travis.yml` file in. It will automatically add the necessary lines.

```
cd /path/to/your/repo
travis encrypt-file ${REPO}_deploy_rsa --add
```

### Add to bastion's known keys

(Contact whomever created the bastion for master $KEY).

```
cat ${REPO}_deploy_rsa.pub | ssh -i $KEY ${BASTION_USER}@${BASTION} 'cat >> .ssh/authorized_keys && echo "Key copied"'
```

### DELETE THE KEYS (IMPORTANT!)

```
rm -f ${REPO}_deploy_rsa ${REPO}_deploy_rsa.pub
```

### Check the edited travis file for formatting and commit

```
open .travis.yml
git add ${REPO}_deploy_rsa.enc .travis.yml
git commit -m "Added encrypted deploy keys"
```

### Add deployment code to .travis.yml

Add env vars that point to the bastion IP and provide the user.

```
addons:
  ssh_known_hosts: $BASTION
deploy:
  provider: script
  skip_cleanup: true
  script: ssh -o StrictHostKeyChecking=no ${BASTION_USER}@${BASTION} ./deploy.sh accounts $COMMIT
  on:
    branch: master
```    

```
git add .travis.yml
git commit -m "Added deployment code."
```

### Push!
Push and merge the code. The deployment will only run when on the master branch.

### Reference
You're travis file should look something like:

```
before_deploy:
  - eval "$(ssh-agent -s)"
  - chmod 600 $TRAVIS_BUILD_DIR/deploy_rsa
  - ssh-add $TRAVIS_BUILD_DIR/deploy_rsa
before_install:
- openssl aes-256-cbc -K $encrypted_9ed86680c859_key -iv $encrypted_9ed86680c859_iv
  -in deploy_rsa.enc -out deploy_rsa -d
addons:
  ssh_known_hosts: $BASTION
deploy:
  provider: script
  skip_cleanup: true
  script: ssh -o StrictHostKeyChecking=no $BASTION_USER@$BASTION ./deploy.sh accounts $COMMIT
  on:
    branch: master
```

The deploy script is located in microservices-demo/deploy. This should be copied to the home directory of the Bastion host.

The bastion should have kubectl symlinked to /usr/local/bin so the script can run it without exports:
`sudo ln -s $HOME/kubernetes/platforms/linux/amd64/kubectl /usr/local/bin/kubectl`
