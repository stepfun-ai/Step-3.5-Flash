# Step-3.5-Flash｜平凡初稿

最近Openrouter上出现了一匹黑马，就是阶跃的Step 3.5 Flash，各方评价都是好用，且非常适配各种agent，尤其是大火的openclaw，看了下技术参数，是一个轻量化的模型，特意在agent上进行了强化，看了下openrouter上的表现，低延迟和高吞吐，的确很符合Agent的调性。

![image](images/image-01.png)
我看了下使用量前五的应用，里面有3个编程的，分别是Roo code，Kilo Code以及Claude code，这个部分很明显很考验大模型的编程以及agent能力；Janitor是一个专门做角色对话的，所以prompt对话的消耗会很大；最后一个就是openclaw，相信大家都听说了，可以算是一个综合性的通用agent，什么都能干，很考验大模型本身的tool use，也就是工具使用能力，因为它本身已经有了很多的技能，需要大模型会智能的选择并执行。

![image](images/image-02.png)
为了验证stepfun-3.5-flash的综合实力，我决定在这个五个平台都部署试一下，不过我不想都按照教程来，稍微整个活。

这是我大概的计划，其中Claude Code（CC）我自己来安装，这个我非常熟了；然后Openclaw本身也是个CLI软件，我就让安装好的Claude Code + stepfun-3.5-flash来给我安装；Roo和Kilo没什么难度，就是个VScode的插件，我自己来配置下即可；最后一个Janitor只能在它的界面配置，所以也是手动。

![image](images/image-03.png)
## 第一步：申请openrouter账号并生成API key

这是最重要的一步，因为没有API key后面的步骤都进行不下去，也很简单直接，注册并登陆openrouter。

<https://openrouter.ai/>

![image](images/image-04.png)
然后在弹出的框里面输入名字（任意名字皆可），然后点击create创建即可。

![image](images/image-05.png)
之后生成的这个key，也就是密钥，只会出现这一次，所以你必须得把它放到一个安全的地方，不过这个模型是免费的，所以可以保存在记事本里。

![image](images/image-06.png)
## 第二步：安装Claude Code并配置stepfun-3.5-flash

这一步在stepfun的官网上其实有教程

<https://github.com/stepfun-ai/Step-3.5-Flash/blob/main/README.zh-CN.md>

其实原理很简单，就是安装CC并把model换成3.5-flash，但是这个教程并没有覆盖Openrouter的教程。

![image](images/image-07.png)
所以我重新做了一个，并且在mac系统里测试没问题，方法其实更简单一些，就三步。

![image](images/image-08.png)
### 第一步：安装环境，打开terminal或者cmd

```bash
# Mac/Linux环境可使用以下命令安装nvm（使用curl）：
# 步骤1
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 安装完复制log输出的最后几行执行
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 中国用户可以设置 npm 镜像源 
npm config set registry https://registry.npmmirror.com

# 步骤2
nvm install v22

# 检查 Node.js 是否安装成功
node --version

npm --version
```

第二步是安装CC，只需要一行代码：

```text
npm install -g @anthropic-ai/claude-code
```

第三步官网没有提到openrouter的使用方式，我建议你用这个方法，把下面这段代码复制粘贴到命令后运行即可，你只需要把「sk-or-你的key」替换成刚刚申请好的key就可以。

```text
OPENROUTER_API_KEY="sk-or-你的key" ANTHROPIC_BASE_URL="https://openrouter.ai/api" ANTHROPIC_AUTH_TOKEN="sk-or-你的key" ANTHROPIC_API_KEY="" claude --model "stepfun/step-3.5-flash:free"
```

这个代码的作用就是把CC默认的模型供应商和模型代号给改成Openrouter和stepfun/step-3.5-flash:free，这里一定注意后面的:free，这个是免费模型的代号，一定得输对，可以参考左边的案例。

![image](images/image-09.png)
这个是简单的验证是否成功的操作。

![image](images/image-10.gif)
回车之后你应该会看到CC的登陆界面，这里面会显示模型是stepfun/step-3.5-flash:free。

![image](images/image-11.png)
你也可以在对话框输入 /status来获取详情。

![image](images/image-12.png)
简单测试一下，输出没问题，速度也很快。

![image](images/image-13.png)
我看了下Openrouter的统计，最慢的也有90多tokens/秒，最高270+，非常快了。

![image](images/image-14.png)
查看方式很简单，点击右上角的个人头像，然后打开activity，就会显示你的token消耗量，主要建议看下我标注的几列，分别是使用的平台、token的使用量（分为输入和输出，价格不同），花费多少以及最后的速度。

![image](images/image-15.png)


## 第三步：用CC来安装openclaw

openclaw的安装其实和CC很像，我让CC帮我来，我就这一句Prompt。

```text
帮我搞定https://github.com/openclaw/openclaw的安装，能最轻量化运行gui即可，我要用https://openrouter.ai/stepfun/step-3.5-flash:free/api，stepfun-3.5这个模型，在openrouter上的，这是api
    key：<我的key>
```

就这么简单，给它openclaw的官方链接、我要配置的模型以及key，剩下的就是一路确定。

你看，这个模型会自动的规划整个过程，先去读安装教程。

![image](images/image-16.png)
安装、配置，特别是在配置的时候，会把我本来需要做的事情一步到位做好，直接把API key给我填上去了。

![image](images/image-17.png)
最后的效果就是这样的，跟我说一切搞定，中间的倒是有过两个错误，但是瞬间也解决了。

![image](images/image-18.png)
然后打开跳出来的网页，Openclaw运行无误，健康状态良好，在后台看所有的设置也都无误。


![image](images/image-19.png)
并且我测试了下用discord调用它，它也可以快速的反应，可以说给我装了一个全天候待命的AI agent，特别是考虑到3.5-flash是免费的，可以说是超值。可能会有同学问discord的配置教程，我跟你说，只需要跟cc说就行，让它帮你跟openclaw进行沟通就行。

![image](images/image-20.png)
## 第四步：Roo + Kilo

这两个非常的像，都是主要活跃在VScode的应用市场里面。

只需要搜索并安装这两个插件即可。

![image](images/image-21.png)
甚至连设置API的界面都几乎一模一样，按照这个设置即可，主要是provider要选openrouter，key是自己申请的那个，模型从下拉框里找到stepfun-3.5-flash:free即可。

Kilo vode

![image](images/image-22.png)
Roo

![image](images/image-23.png)
我让这俩插件都生成了贪吃蛇游戏，可以看到不同的地方调用了同样的模型，结果基本上一样，一致性还是很强的。

![image](images/image-24.png)

## 第五步：jantior AI设置

形式很简单，就是角色扮演，你可以跟对方对话，它平台本身有自己的模型，但是也可以用第三方平台的。

![image](images/image-25.png)
在API设置这里，选择Proxy，然后选择添加configuration。

![image](images/image-26.png)
设置按我这个就行，自己替换掉API Key那一栏即可。

![image](images/image-27.png)
设置好保存，之后随便找一个角色对话，只要对方有回应，那就说明设置成功了。

![image](images/image-28.png)

## 总结

可以看到这五个应用其实有相似，但也不太一样，特别是最后一个的角色扮演，它其实用不到什么agent的能力，就是纯粹的prompt对话；而剩下的几个都需要很强的agent能力，特别是coding。

从CC可以独立安装openclaw来看，step-3.5-flash这个模型的实力很过硬，特别是加上它的低延迟和高吞吐，是一个非常适合当下火热的agent架构的。再叠加免费这一点：对个人开发者/内容创作者来说是极高性价比的通用底座模型。
