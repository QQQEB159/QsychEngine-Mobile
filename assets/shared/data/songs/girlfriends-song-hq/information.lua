local popupVisible = false

function onCreate()
    -- 背景
    makeLuaSprite('popupBg', nil, 15, 15)
    makeGraphic('popupBg', 380, 150, '000000')
    setProperty('popupBg.alpha', 0)
    setObjectCamera('popupBg', 'camHUD')
    addLuaSprite('popupBg', true)

    -- 标题
    makeLuaText('popupTitle', '', 360, 25, 25)
    setObjectCamera('popupTitle', 'camHUD')
    setTextSize('popupTitle', 22)
    setTextColor('popupTitle', 'FFFFFF')
    setTextBorder('popupTitle', 2, '000000')
    setTextFont('popupTitle', 'vcr.ttf')   -- 如需中文，请替换为支持中文的字体
    setProperty('popupTitle.alpha', 0)
    addLuaText('popupTitle')

    -- 第1行
    makeLuaText('popupLine1', '', 360, 25, 55)
    setObjectCamera('popupLine1', 'camHUD')
    setTextSize('popupLine1', 18)
    setTextColor('popupLine1', 'CCCCCC')
    setTextBorder('popupLine1', 1, '000000')
    setTextFont('popupLine1', 'vcr.ttf')
    setProperty('popupLine1.alpha', 0)
    addLuaText('popupLine1')

    -- 第2行
    makeLuaText('popupLine2', '', 360, 25, 80)
    setObjectCamera('popupLine2', 'camHUD')
    setTextSize('popupLine2', 18)
    setTextColor('popupLine2', 'CCCCCC')
    setTextBorder('popupLine2', 1, '000000')
    setTextFont('popupLine2', 'vcr.ttf')
    setProperty('popupLine2.alpha', 0)
    addLuaText('popupLine2')

    -- 第3行
    makeLuaText('popupLine3', '', 360, 25, 105)
    setObjectCamera('popupLine3', 'camHUD')
    setTextSize('popupLine3', 18)
    setTextColor('popupLine3', 'CCCCCC')
    setTextBorder('popupLine3', 1, '000000')
    setTextFont('popupLine3', 'vcr.ttf')
    setProperty('popupLine3.alpha', 0)
    addLuaText('popupLine3')

    -- 第4行（备用）
    makeLuaText('popupLine4', '', 360, 25, 130)
    setObjectCamera('popupLine4', 'camHUD')
    setTextSize('popupLine4', 18)
    setTextColor('popupLine4', 'CCCCCC')
    setTextBorder('popupLine4', 1, '000000')
    setTextFont('popupLine4', 'vcr.ttf')
    setProperty('popupLine4.alpha', 0)
    addLuaText('popupLine4')
end

-- 设置中文文本
function setChineseText()
    local songName = getProperty('songName') or 'Sorrow-Brew'
    local artist = 'High Quality Funkin'
    local coder = 'Icon-BF'

    setTextString('popupTitle', '歌曲信息')
    setTextString('popupLine1', '歌名：' .. songName)
    setTextString('popupLine2', '使用模组歌曲：' .. artist)
    setTextString('popupLine3', '制作：' .. coder)
    setTextString('popupLine4', '')
end

-- 设置英文文本
function setEnglishText()
    local songName = getProperty('songName') or 'Sorrow-Brew'
    local artist = 'High Quality Funkin'
    local coder = 'Icon-BF'

    setTextString('popupTitle', 'Song Info')
    setTextString('popupLine1', 'Song: ' .. songName)
    setTextString('popupLine2', 'Mod: ' .. artist)
    setTextString('popupLine3', 'Made by: ' .. coder)
    setTextString('popupLine4', '')
end

-- 渐入所有元素
function fadeInAll(duration, ease)
    doTweenAlpha('fadeInBg', 'popupBg', 1, duration, ease)
    doTweenAlpha('fadeInTitle', 'popupTitle', 1, duration, ease)
    doTweenAlpha('fadeInLine1', 'popupLine1', 1, duration, ease)
    doTweenAlpha('fadeInLine2', 'popupLine2', 1, duration, ease)
    doTweenAlpha('fadeInLine3', 'popupLine3', 1, duration, ease)
    doTweenAlpha('fadeInLine4', 'popupLine4', 1, duration, ease)
end

-- 淡出所有元素
function fadeOutAll(duration, ease)
    doTweenAlpha('fadeOutBg', 'popupBg', 0, duration, ease)
    doTweenAlpha('fadeOutTitle', 'popupTitle', 0, duration, ease)
    doTweenAlpha('fadeOutLine1', 'popupLine1', 0, duration, ease)
    doTweenAlpha('fadeOutLine2', 'popupLine2', 0, duration, ease)
    doTweenAlpha('fadeOutLine3', 'popupLine3', 0, duration, ease)
    doTweenAlpha('fadeOutLine4', 'popupLine4', 0, duration, ease)
end

function onSongStart()
    -- 第一阶段：显示中文
    setChineseText()
    popupVisible = true
    fadeInAll(0.3, 'quadOut')
    -- 中文显示4秒后开始淡出
    runTimer('phase1_end', 4.3, 1)  -- 0.3秒渐入 + 4秒停留
end

function onTimerCompleted(tag)
    if tag == 'phase1_end' then
        -- 淡出中文
        fadeOutAll(0.5, 'quadIn')
        -- 等待淡出完成后切换到英文（0.5秒后）
        runTimer('phase2_show', 0.5, 1)
    elseif tag == 'phase2_show' then
        -- 设置英文文本并淡入
        setEnglishText()
        fadeInAll(0.3, 'quadOut')
        -- 英文显示4秒后开始淡出
        runTimer('phase2_end', 4.3, 1)
    elseif tag == 'phase2_end' then
        -- 淡出英文
        fadeOutAll(0.5, 'quadIn')
        -- 淡出完成后结束
        runTimer('finish', 0.5, 1)
    elseif tag == 'finish' then
        popupVisible = false
        -- 完全隐藏（可选）
    end
end