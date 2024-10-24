@echo off
chcp 65001 > nul
echo.
echo 请输入commit注释
set /p COMMIT_MSG=:

git add .
	
git commit -m "%COMMIT_MSG%"

git push

echo.
echo 文件夹内容已成功上传到 Gitee 上！
set /p c=按回车键退出...