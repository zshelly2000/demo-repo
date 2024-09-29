#I am basically following this well made written tutorial for reference:
# https://sites.northwestern.edu/researchcomputing/resources/using-git-and-github-with-r-rstudio/
# https://sites.northwestern.edu/researchcomputing/2022/05/11/git-with-rstudio-order-matters/

#install.packages("usethis")

#set up email using git bash command: 
# git config --global user.name "John Doe"
# git config --global user.email johndoe@example.com

#or you can use this command in R with usethis package:
usethis::use_git_config(user.name="Zach Shelly", user.email="zshelly2000@gmail.com")

#set up a personal access token to link online github profile to R environement.
# go to https://github.com/settings/tokens and click “Generate token”.
# or
# from R do this:
#usethis::create_github_token()

#use the following code to get a prompt where you can paste your PAT (personal access token):
gitcreds::gitcreds_set()
