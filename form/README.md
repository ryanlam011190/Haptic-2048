# Form for creating an experiment on the Haptics Platform
https://hapticstestplatform.herokuapp.com/

Heroku commands:
* For initial setup, log in to the Heroku CLI and run this command only for your first deployment after cloning this repo: `heroku git:remote -a hapticstestplatform`
* The form is deployed from only the form/ subdirectory of this repo, so after pushing any new changes to github, deploy the changes to the above link with this command (make sure to run this from the main Haptics-2048/ folder, not inside form/): `git subtree push --prefix form heroku main` 
* To restart the app: `heroku restart -a hapticstestplatform`
* To view logs in terminal: `heroku logs --tail -a hapticstestplatform`
