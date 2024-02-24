#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

TEX_FILE=book.tex
cd build/latex

# 给所有的标题加一个层级

if ! grep '\\part' $TEX_FILE; then
  sed -i 's/\\chapter/\\part/g' $TEX_FILE
  sed -i 's/\\section/\\chapter/g' $TEX_FILE
  sed -i 's/\\subsection/\\section/g' $TEX_FILE
  sed -i 's/\\subsubsection/\\subsection/g' $TEX_FILE
  sed -i 's/\\paragraph/\\subsubsection/g' $TEX_FILE
  sed -i 's/\\subparagraph/\\paragraph/g' $TEX_FILE
fi

# Sphinx bug导致要手动将目录移动到引言部分后
# 先删除目录那行及其之前一行
# 只要不为最后一行就将下一行添加到pattern空间；
# 只要pattern空间没有这句就print；
# 清除pattern空间，进入下一行
sed -i '$!N;/sphinxtableofcontents/!P;D' $TEX_FILE
# 再在第一个sphinxstepscope之下新建目录
# 在从第一行到首次匹配的所有行中，对匹配到的行进行追加
sed -i '1,/sphinxstepscope/{/sphinxstepscope/a\\\\'\
'pagestyle{plain}\n\\sphinxtableofcontents\n\\'\
$'pagestyle{normal}\n}' $TEX_FILE

# 好了，开始做pdf
make

cd ../..
