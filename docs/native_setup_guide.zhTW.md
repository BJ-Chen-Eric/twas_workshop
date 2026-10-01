# Workshop 環境設定指南

**寫給完全的新手——如果你從來沒用過終端機,請從最上面開始,照順序
一步步做。** 如果你已經知道終端機/venv/pip 是什麼,可以直接跳到
[快速版](#快速版)。

這個設定只需要 Python 本身——不用另外裝別的東西。所有 toy data
(權重模型跟 GWAS summary statistics 檔)第一次執行 setup 時都會自動
從 Zenodo 下載。

---

## Step 1 —— 下載這個 workshop 資料夾

1. 在瀏覽器裡打開這個 repo 的 GitHub 頁面。
2. 點綠色的 **`<> Code`** 按鈕,再點 **`Download ZIP`**。
3. 找到下載下來的 `.zip` 檔(通常在你的「下載」資料夾裡),**解壓縮**
   ——Mac 上雙擊就可以;Windows 上右鍵點它,選**全部解壓縮**。
4. 把解壓縮出來的資料夾放到容易找到的地方,例如桌面。

*(如果你已經會用 git,`git clone` 也可以——上面是不用 git 的做法。)*

## Step 2 —— 在 *workshop 資料夾裡*打開終端機

你的終端機目前所在的位置,必須真的是 Step 1 那個資料夾,不能隨便一個
地方。

**Mac**:打開 **Finder**,找到 workshop 資料夾,然後:
- 右鍵點資料夾 → **「在檔案夾中打開終端機」**(如果有這個選項),或者
- 正常打開終端機,輸入 `cd `(後面留一個空格,先不要按 Enter),然後
  **把 Finder 裡那個資料夾拖進終端機視窗**——它會自動貼上完整路徑——
  再按 Enter。

**Windows**:打開**檔案總管**,進入 workshop 資料夾,點上方的網址列,
輸入 `powershell`,按 Enter——這樣會直接在那個資料夾裡打開 PowerShell。

**Linux**:跟 Mac 概念一樣——`cd ` + 拖曳,或是如果你的檔案管理員有提供
「在此開啟終端機」的右鍵選項也可以用。

**確認你在正確的位置**:輸入 `ls`(Mac/Linux)或 `dir`(Windows)再按
Enter——應該會看到 `requirements.txt` 跟一個 `script` 資料夾之類的檔案。
如果沒有,代表你在錯的目錄。

## Step 3 —— 執行那支唯一的 setup 腳本

**Mac**:
```bash
bash script/mac/setup.sh
```
**Windows**:
```powershell
script\windows\setup.bat
```

這一支腳本(不用再打別的指令)——**連檢查有沒有裝 Python 都包在裡面
了**,所以這真的是唯一需要執行的指令:
1. 檢查有沒有 Python。如果沒有,會提供**特別指定 Python 3.11**
   (不是「隨便最新版」)的自動安裝選項,先問是/否(因為需要你的
   密碼/確認):Mac 上透過 Homebrew(需要的話先裝 Homebrew 本身);
   Windows 上透過 `winget`。選不要的話,就印出手動安裝連結然後停下來
   ——裝好 Python 之後重新執行同一個指令就好。
2. 建立一個獨立的 Python 環境(`venv/`)——確保底下這些東西不會碰到/
   衝突到你電腦上其他東西。
3. 把需要的套件裝進那個環境。
4. 從 Zenodo 下載 toy data(權重模型跟 GWAS 檔)。
5. 檢查一切是不是真的準備好了,如果缺什麼會清楚告訴你。

執行過程中會印出進度。第一次執行要花幾分鐘(下載套件 + 資料);之後
隨時可以重複執行都沒關係——它會跳過已經做好的部分,如果之前中途失敗
過,也會自動清掉重新開始。

**如果最後印出任何 `MISSING` 的訊息**,見下面的
[疑難排解](#疑難排解)。

## Step 4 —— 執行 workshop 分析

**Mac / Linux**:
```bash
bash script/run_native_tissue.sh
```
**Windows**(或任何你不想用 bash 的地方):
```powershell
venv\Scripts\python.exe script\run_native_tissue.py
```
```bash
venv/bin/python script/run_native_tissue.py    # Mac/Linux 也可以這樣用
```

這會針對兩個組織實際跑一次 TWAS 分析(S-PrediXcan),把結果寫進新的
`out/` 資料夾。

**選用——cell-type 這條線**:用同樣方式執行
`script/run_native_singlecell.sh`(Windows 上是 `.py`)。這條用的是
不同的方法(個人層級的 `PrediXcan.py`),針對的是**合成**基因型資料
(不是真實個人——從真實的等位基因頻率模擬出來的,詳見
`script/run_native_singlecell.py` 裡的說明),所以結果本來就會接近
統計雜訊——這條線是用來示範個人層級的流程能跑起來,不是真的生物學
發現。當成附加內容看待就好。

---

## 快速版

給已經很習慣用終端機的人:
```bash
# 1. 下載並解壓縮這個 repo,cd 進去之後:
bash script/mac/setup.sh             # 檢查 Python、venv、安裝、下載資料、檢查
bash script/run_native_tissue.sh     # 或:venv/bin/python script/run_native_tissue.py
bash script/run_native_singlecell.sh # 選用的 cell-type 線(合成資料)
```
Windows:`script\windows\setup.bat`,然後
`venv\Scripts\python.exe script\run_native_tissue.py`。

套件清單(見 `requirements.txt`):`numpy<2.0`、`pandas<2.0`、`scipy`、
`patsy`、`h5py`、`sqlalchemy<2.0`、`pyliftover`、`statsmodels`。工具本身
(`tools/MetaXcan-master/software/`)包在 repo 裡;toy 權重模型
(約 130MB)跟 GWAS 檔(約 31MB)都會自動從 Zenodo 下載。

## 選用:用雙擊取代打字

Step 3 的腳本不管打字執行還是雙擊,做的事完全一樣:
- **Mac**:雙擊 `script/mac/setup.command`。如果 macOS 第一次跳出警告,
  右鍵點檔案 → **打開** → 確認。
- **Windows**:直接雙擊 `script\windows\setup.bat`(它本來就是雙擊用的形式)。
  如果 Windows 顯示「Windows 已保護你的電腦」,點**其他資訊** →
  **仍要執行**。

(這些警告對任何從網路上下載、不是來自已註冊發行者的腳本來說都很正常
——不代表哪裡出錯了。)

## 疑難排解

- **Step 3 說找不到 Python**:它會直接印出連結跟該怎麼做——裝好
  Python,打開一個新的終端機,再重跑一次 Step 3。
- **Windows 上出現「Microsoft Visual C++ 14.0 or greater is
  required」的錯誤**:代表最後是用 3.12+ 編譯而不是 3.11(pandas 在
  3.12+ 上需要 C/C++ 編譯器才能編譯,大部分電腦都沒裝)。手動安裝
  Python 3.11(`winget install -e --id Python.Python.3.11`),然後明確
  指定用 `py -3.11 script\setup.py` 重新執行 setup——不要在現場花時間
  裝 C++ 編譯器。
- **雙擊 `setup.command` 或 `setup.bat` 時出現權限/安全性警告**:對
  下載下來的腳本來說是正常的,見上面的說明——或者乾脆改用 Step 3
  打字執行的版本,就不會跳出這些警告。
- **本來好好的,pip 突然開始出現看不懂的「Invalid version」錯誤**:
  如果這個 workshop 資料夾放在雲端同步的資料夾裡(iCloud Drive、
  Dropbox、OneDrive、Google Drive),同步服務可能會在 pip 寫入 `venv/`
  時建立衝突複本,把某個套件的版本資訊弄壞到讓後續所有安裝都失敗的
  程度。解法:把整個 `venv` 資料夾刪掉,重跑一次 Step 3 讓它重新建立。
  如果一直發生,把這個資料夾搬到雲端同步範圍以外。
- **其他看起來怪怪的地方**:重新執行一次 Step 3
  (`bash script/mac/setup.sh` / `script\windows\setup.bat`)——重複執行
  很安全,它會清楚重新回報到底缺什麼。

## 為什麼不用 Docker?

Docker 是原本的計畫,而且真的可以動——但實際安裝 Docker Desktop 本身,
結果又慢又麻煩,而且一旦確定實際的分析只需要幾個單純可以用 pip 裝的
Python 套件(不用 conda,沒有什麼奇怪的東西),虛擬環境就可以做一模
一樣的事,要裝的東西少很多,可能出錯的地方也少很多。
