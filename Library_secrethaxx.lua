do --// UI Source
    if getgenv().Library and getgenv().Library.Exit then
        getgenv().Library:Exit()
    end

    -- Bad executor support (atleast by a bit)
    cloneref = cloneref or function(Object) return Object end

    --#region Services
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local GuiService = game:GetService("GuiService")
    local CoreGui = cloneref(game:GetService("CoreGui"))
    --#endregion

    gethui = gethui or function() return CoreGui end

    --#region Variables
    local LocalPlayer = Players.LocalPlayer
    local IsMobile = UserInputService.TouchEnabled or false
    local GuiInset = GuiService:GetGuiInset().Y
    local Mouse = cloneref(LocalPlayer:GetMouse())
    --#endregion

    Library = {
        Flags = { },
        MenuKeybind = tostring(Enum.KeyCode.X),

        Directory = "Radiance",
        Folders = {
            Assets = "/Assets",
            Configs = "/Configs"
        },

        FontSize = 12,

        Animation = {
            Time = 0.3,
            Style = "Exponential",
            Direction = "Out"
        },

        ZIndexOrder = {
            ["OptionHolder"] = 4,
            ["KeybindWindow"] = 4, -- burp
            ["ColorpickerWindow"] = 6
        },

        Theme = nil,

        -- Ignore below
        Threads = { },
        Connections = { },
        SetFlags = { },

        ThemingStuff = { },
        ThemeMap = { },

        OpenFrames = { },

        Holder = nil,
        UnusedHolder = nil,

        Font = nil,
        BoldFont = nil,
    } do
        Library.__index = Library

        local Flags = Library.Flags
        local SetFlags = Library.SetFlags
        local ConfigsFolder = Library.Directory .. Library.Folders.Configs .. "/"
        local ConfigSelected
        local ConfigName

        local Keys = {
            ["Unknown"]           = "Unknown",
            ["Backspace"]         = "Back",
            ["Tab"]               = "Tab",
            ["Clear"]             = "Clear",
            ["Return"]            = "Return",
            ["Pause"]             = "Pause",
            ["Escape"]            = "Esc",
            ["Space"]             = "Space",
            ["QuotedDouble"]      = '"',
            ["Hash"]              = "#",
            ["Dollar"]            = "$",
            ["Percent"]           = "%",
            ["Ampersand"]         = "&",
            ["Quote"]             = "'",
            ["LeftParenthesis"]   = "(",
            ["RightParenthesis"]  = ")",
            ["Asterisk"]          = "*",
            ["Plus"]              = "+",
            ["Comma"]             = ",",
            ["Minus"]             = "-",
            ["Period"]            = ".",
            ["Slash"]             = "/",
            ["Three"]             = "3",
            ["Seven"]             = "7",
            ["Eight"]             = "8",
            ["Colon"]             = ":",
            ["Semicolon"]         = ";",
            ["LessThan"]          = "<",
            ["GreaterThan"]       = ">",
            ["Question"]          = "?",
            ["Equals"]            = "=",
            ["At"]                = "@",
            ["LeftBracket"]       = "[",
            ["RightBracket"]      = "]",
            ["BackSlash"]         = "\\",
            ["Caret"]             = "^",
            ["Underscore"]        = "_",
            ["Backquote"]         = "`",
            ["LeftCurly"]         = "{",
            ["Pipe"]              = "|",
            ["RightCurly"]        = "}",
            ["Tilde"]             = "~",
            ["Delete"]            = "Del",
            ["End"]               = "End",
            ["KeypadZero"]        = "N0",
            ["KeypadOne"]         = "N1",
            ["KeypadTwo"]         = "N2",
            ["KeypadThree"]       = "N3",
            ["KeypadFour"]        = "N4",
            ["KeypadFive"]        = "N5",
            ["KeypadSix"]         = "N6",
            ["KeypadSeven"]       = "N7",
            ["KeypadEight"]       = "N8",
            ["KeypadNine"]        = "N9",
            ["KeypadPeriod"]      = "N.",
            ["KeypadDivide"]      = "N/",
            ["KeypadMultiply"]    = "N*",
            ["KeypadMinus"]       = "N-",
            ["KeypadPlus"]        = "N+",
            ["KeypadEnter"]       = "NEnt",
            ["KeypadEquals"]      = "N=",
            ["Insert"]            = "Ins",
            ["Home"]              = "Hm",
            ["PageUp"]            = "PgU",
            ["PageDown"]          = "PgD",
            ["RightShift"]        = "RShift",
            ["LeftShift"]         = "LShift",
            ["RightControl"]      = "RCtrl",
            ["LeftControl"]       = "LCtrl",
            ["LeftAlt"]           = "LAlt",
            ["RightAlt"]          = "RAlt",
            ["MouseButton1"]      = "M1",
            ["MouseButton2"]      = "M2",
            ["MouseButton3"]      = "M3"
        }

        -- Folders
        if not isfolder(Library.Directory) then
            makefolder(Library.Directory)
        end

        for _, Folder in Library.Folders do
            if not isfolder(Library.Directory .. Folder) then
                makefolder(Library.Directory .. Folder)
            end
        end

        local Themes = {
            ["Preset"] = {
                ["Background"] = Color3.fromRGB(23, 23, 23),
                ["Inline"] = Color3.fromRGB(22, 22, 22),
                ["Content"] = Color3.fromRGB(21, 21, 21),
                ["Text"] = Color3.fromRGB(200, 200, 200),
                ["Outline 1"] = Color3.fromRGB(35, 35, 35),
                ["Outline 2"] = Color3.fromRGB(30, 30, 30),
                ["Outline 3"] = Color3.fromRGB(15, 15, 15),
                ["Outline 4"] = Color3.fromRGB(10, 10, 10),
                ["Inactive Text"] = Color3.fromRGB(135, 135, 135),
                ["Accent"] = Color3.fromRGB(126, 192, 255), -- 126, 192, 255
                ["Hovered Element"] = Color3.fromRGB(35, 35, 35),
            }
        }

        Library.Theme = Themes.Preset

        -- Custom Font
        local CustomFont = { } do
            function CustomFont:New(Name, Weight, Style, Data)
                if not isfile(Data.Id) then
                    writefile(Data.Id, game:HttpGet(Data.Url))
                end

                local Data = {
                    name = Name,
                    faces = {
                        {
                            name = Name,
                            weight = Weight,
                            style = Style,
                            assetId = getcustomasset(Data.Id)
                        }
                    }
                }

                local FontPath = Library.Directory .. Library.Folders.Assets .. "/" .. Name .. ".font"
                writefile(FontPath, HttpService:JSONEncode(Data))
                return Font.new(getcustomasset(FontPath))
            end

            Library.Font = CustomFont:New("WindowsXPTAHOMA", 400, "Regular", {
                Id = "WindowsXPTAHOMA",
                Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/windows-xp-tahoma.ttf"
            })

            Library.BoldFont = CustomFont:New("Tahoma8PTBOLD", 400, "Regular", {
                Id = "Tahoma8PTBOLD",
                Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/TAHOMA-8PT-BOLD-WINDOWS-XP.TTF"
            })
        end

        Library.Exit = function(Self)
            for _, Connection in Library.Connections do
                Connection:Disconnect()
            end

            for _, Thread in Library.Threads do
                coroutine.close(Thread)
            end

            if Self.Holder then
                Self.Holder.Instance:Destroy()
            end

            if Self.UnusedHolder then
                Self.UnusedHolder.Instance:Destroy()
            end

            Library = nil
            getgenv().Library = nil
        end

        Library.Create = function(Self, Class, Properties)
            local Data = {
                Class = Class,
                Properties = Properties,
                Instance = Instance.new(Class)
            }

            for Index, Property in Properties do
                if Property == "FontFace" then
                    Data.Instance[Property] = Library.Font
                elseif Property == "TextSize" then
                    Data.Instance[Property] = Library.FontSize
                elseif Property == "Name" then
                    Data.Instance[Property] = "\0"
                elseif Class == "TextButton" and Property == "AutoButtonColor" then
                    Data.Instance[Property] = false
                elseif Class == "TextButton" and Property == "Text" then
                    Data.Instance[Property] = ""
                else
                    Data.Instance[Index] = Property
                end
            end

            return setmetatable(Data, Library)
        end

        Library.Thread = function(Self, Function)
            local NewThread = coroutine.create(Function)

            coroutine.wrap(function()
                coroutine.resume(NewThread)
            end)()

            table.insert(Library.Threads, NewThread)
            return NewThread
        end

        Library.Connect = function(Self, Signal, Callback)
            local Connection

            if Self.Instance then
                if Self.Instance[Signal] then
                    if IsMobile and Signal == "MouseButton1Down" then
                        Connection = Self.Instance.InputBegan:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
                                Callback(Input)
                            end
                        end)

                        return
                    end

                    Connection = Self.Instance[Signal]:Connect(Callback)
                else
                    Connection = Signal:Connect(Callback)
                end
            else
                Connection = Signal:Connect(Callback)
            end

            table.insert(Library.Connections, Connection)
            return Connection
        end

        Library.Tween = function(Self, Properties, Info, IsRawItem)
            local Object = Self.Instance or IsRawItem
            Info = Info or TweenInfo.new(Library.Animation.Time, Enum.EasingStyle[Library.Animation.Style], Enum.EasingDirection[Library.Animation.Direction])

            if not Object then
                return
            end

            local NewTween = TweenService:Create(Object, Info, Properties)
            NewTween:Play()

            if Object:IsA("TextLabel") then
                local Stroke = Object:FindFirstChildOfClass("UIStroke")

                if Stroke and Properties.TextTransparency then
                    TweenService:Create(Stroke, Info, {
                        Transparency = Properties.TextTransparency
                    }):Play()
                end
            end

            return NewTween
        end

        Library.GetTweenProperty = function(Self, IsRawItem)
            local Object = Self.Instance or IsRawItem

            if not Object then
                return { }
            end

            if Object:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Object:IsA("TextLabel") or Object:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Object:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Object:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Object:IsA("UIStroke") then
                return { "Transparency" }
            end
        end

        Library.Fade = function(Self, Property, Visibility, IsRawItem)
            local Object = Self.Instance or IsRawItem

            if not Object then
                return
            end

            local OldTransparency = Object[Property]
            Object[Property] = Visibility and 1 or OldTransparency

            local NewTween = Library:Tween({
                [Property] = Visibility and OldTransparency or 1
            }, nil, Object)

            Library:Connect(NewTween.Completed, function()
                if not Visibility then
                    task.wait()
                    Object[Property] = OldTransparency
                end
            end)

            return NewTween
        end

        Library.FadeDescendants = function(Self, Visibility, Callback)
            if Visibility then
                Self.Instance.Visible = true
            end

            local NewTween

            local Children = Self.Instance:GetDescendants()
            table.insert(Children, Self.Instance)

            for _, Child in Children do
                local TransparencyProperty = Library:GetTweenProperty(Child)

                if TransparencyProperty then
                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do
                            NewTween = Library:Fade(Property, Visibility, Child)
                        end
                    else
                        NewTween = Library:Fade(TransparencyProperty, Visibility, Child)
                    end
                end
            end

            Library:Connect(NewTween.Completed, function()
                if Callback and type(Callback) == "function" then
                    Callback()
                end

                Self.Instance.Visible = Visibility
            end)
        end

        Library.MakeDraggable = function(Self)
            if not Self.Instance then
                return
            end

            local Gui = Self.Instance
            local Dragging = false
            local DragStart
            local StartPosition

            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y

                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize

                NewX = math.clamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = math.clamp(NewY, 0, ScreenSize.Y - GuiSize.Y)

                Self:Tween({Position = UDim2.new(0, NewX, 0, NewY)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end

            local InputChanged

            Self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position

                    if InputChanged then
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)

            return Dragging
        end

        Library.MakeResizeable = function(Self, Minimum)
            if not Self.Instance then
                return
            end

            local Gui = Self.Instance

            local Resizing = false
            local CurrentSide = nil

            local StartMouse = nil
            local StartPosition = nil
            local StartSize = nil

            local EdgeThickness = 2

            local MakeEdge = function(Name, Position, Size)
                local Button = Library:Create("TextButton", {
                    Name = "\0",
                    Size = Size,
                    Position = Position,
                    BackgroundColor3 = Color3.fromRGB(166, 147, 243),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = Gui,
                    ZIndex = 99999,
                })  Button:AddToTheme({BackgroundColor3 = "Accent"})

                return Button
            end

            local Edges = {
                {Button = MakeEdge(
                    "Left",
                    UDim2.new(0, 0, 0, 0),
                    UDim2.new(0, EdgeThickness, 1, 0)),
                    Side = "L"
                },

                {Button = MakeEdge(
                    "Right",
                    UDim2.new(1, -EdgeThickness, 0, 0),
                    UDim2.new(0, EdgeThickness, 1, 0)),
                    Side = "R"
                },

                {Button = MakeEdge(
                    "Top", UDim2.new(0, 0, 0, 0),
                    UDim2.new(1, 0, 0, EdgeThickness)),
                    Side = "T"
                },

                {Button = MakeEdge(
                    "Bottom",
                    UDim2.new(0, 0, 1, -EdgeThickness),
                    UDim2.new(1, 0, 0, EdgeThickness)),
                    Side = "B"
                },
            }

            local BeginResizing = function(Side)
                Resizing = true
                CurrentSide = Side

                StartMouse = UserInputService:GetMouseLocation()

                StartPosition = Vector2.new(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                StartSize = Vector2.new(Gui.Size.X.Offset, Gui.Size.Y.Offset)

                for Index, Value in Edges do
                    Value.Button.Instance.BackgroundTransparency = (Value.Side == Side) and 0 or 1
                end
            end

            local EndResizing = function()
                Resizing = false
                CurrentSide = nil

                for Index, Value in Edges do
                    Value.Button.Instance.BackgroundTransparency = 1
                end
            end

            for Index, Value in Edges do
                Value.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        BeginResizing(Value.Side)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Resizing then
                        EndResizing()
                    end
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not Resizing or not CurrentSide then
                    return
                end

                local MouseLocation = UserInputService:GetMouseLocation()
                local dx = MouseLocation.X - StartMouse.X
                local dy = MouseLocation.Y - StartMouse.Y

                local x, y = StartPosition.X, StartPosition.Y
                local w, h = StartSize.X, StartSize.Y

                if CurrentSide == "L" then
                    x = StartPosition.X + dx
                    w = StartSize.X - dx
                elseif CurrentSide == "R" then
                    w = StartSize.X + dx
                elseif CurrentSide == "T" then
                    y = StartPosition.Y + dy
                    h = StartSize.Y - dy
                elseif CurrentSide == "B" then
                    h = StartSize.Y + dy
                end

                if w < Minimum.X then
                    if CurrentSide == "L" then
                        x = x - (Minimum.X - w)
                    end
                    w = Minimum.X
                end
                if h < Minimum.Y then
                    if CurrentSide == "T" then
                        y = y - (Minimum.Y - h)
                    end
                    h = Minimum.Y
                end

                Self:Tween({Position = UDim2.fromOffset(x, y)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                Self:Tween({Size = UDim2.fromOffset(w, h)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end)
        end

        Library.IsMouseOverFrame = function(Self)
            if not Self.Instance then
                return
            end

            local Object = Self.Instance

            local MousePosition = Vector2.new(Mouse.X, Mouse.Y)

            return MousePosition.X >= Object.AbsolutePosition.X and MousePosition.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
            and MousePosition.Y >= Object.AbsolutePosition.Y and MousePosition.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
        end

        Library.SafeCall = function(Self, Function, ...)
            local Arguements = { ... }
            local Success, Result = pcall(Function, table.unpack(Arguements))

            if not Success then
                warn(Result)
                return false
            end

            return Success, Result
        end

        Library.Round = function(Self, Number, Float)
            Float = Float or 1
            if Float <= 0 then Float = 1 end
            if Float >= 2 and math.floor(Float) == Float and Float <= 6 then
                Float = 10 ^ (-Float)
            end
            local Multiplier = 1 / Float
            return math.floor(Number * Multiplier + 0.5) / Multiplier
        end

        Library.GetConfig = function(Self)
            local Config = { }

            local Success, Result = Library:SafeCall(function()
                for Index, Value in Library.Flags do
                    if type(Value) == "table" and Value.Key then
                        Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                    elseif type(Value) == "table" and Value.Color then
                        Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                    else
                        Config[Index] = Value
                    end
                end
            end)

            if not Success then
                warn("Failed to get config:\n"..Result)
                return
            end

            return HttpService:JSONEncode(Config)
        end

        Library.LoadConfig = function(Self, Config)
            local Decoded = HttpService:JSONDecode(Config)

            local Success, Result = Library:SafeCall(function()
                for Index, Value in Decoded do
                    local SetFunction = Library.SetFlags[Index]

                    if SetFunction then
                        if type(Value) == "table" and Value.Key then
                            SetFunction(Value)
                        elseif type(Value) == "table" and Value.Color then
                            SetFunction(Value.Color, Value.Alpha)
                        else
                            SetFunction(Value)
                        end
                    end
                end
            end)

            return Success, Result
        end

        Library.GetConfigsList = function(Self, Element)
            local List = { }
            local ReturnList = { }

            List = listfiles(Library.Directory .. Library.Folders.Configs)

            for Index = 1, #List do
                local File = List[Index]

                if File:sub(-5) == ".json" then
                    local Position = File:find(".json", 1, true)
                    local StartPosition = Position

                    local Character = File:sub(Position, Position)
                    while Character ~= "/" and Character ~= "\\" and Character ~= "" do
                        Position = Position - 1
                        Character = File:sub(Position, Position)
                    end

                    if Character == "/" or Character == "\\" then
                        table.insert(ReturnList, File:sub(Position + 1, StartPosition - 1))
                    end
                end
            end

            Element:Refresh(ReturnList)
        end

        Library.AddToTheme = function(Self, Properties)
            local Object = Self.Instance

            local ThemeData = {
                Item = Object,
                Properties = Properties,
            }

            for Property, Value in ThemeData.Properties do
                if type(Value) == "string" then
                    if not Library.Theme[Value] then
                        Object[Property] = Value
                    end

                    Object[Property] = Library.Theme[Value]
                else
                    Object[Property] = Value()
                end
            end

            table.insert(Library.ThemingStuff, ThemeData)
            Library.ThemeMap[Object] = ThemeData
            return Self
        end

        Library.ChangeItemTheme = function(Self, Properties)
            local Object = Self.Instance

            if not Library.ThemeMap[Object] then
                return
            end

            Library.ThemeMap[Object].Properties = Properties
            Library.ThemeMap[Object] = Library.ThemeMap[Object]
        end

        Library.ChangeTheme = function(Self, Theme, Color)
            Library.Theme[Theme] = Color

            for _, Item in Library.ThemingStuff do
                for Property, Value in Item.Properties do
                    if type(Value) == "string" and Value == Theme then
                        Item.Item[Property] = Color
                    elseif type(Value) == "function" then
                        Item.Item[Property] = Value()
                    end
                end
            end
        end

        Library.OnHover = function(Self, OnHoverEnter, OnHoverLeave)
            local Object = Self.Instance

            if not Object then
                return
            end

            Library:Connect(Object.MouseEnter, OnHoverEnter)
            Library:Connect(Object.MouseLeave, OnHoverLeave)
        end

        Library.Holder = Library:Create("ScreenGui", {
            Parent = gethui(),
            IgnoreGuiInset = true,
            Name = "\0",
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            ResetOnSpawn = false
        })

        Library.UnusedHolder = Library:Create("ScreenGui", {
            Parent = gethui(),
            Name = "\0",
            Enabled = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            ResetOnSpawn = false
        })

        Library.NotifHolder = Library:Create("Frame", {
            Name = "\0",
            Parent = Library.Holder.Instance,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X
        })

        Library:Create("UIListLayout", {
            Name = "\0",
            Parent = Library.NotifHolder.Instance,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        Library:Create("UIPadding", {
            Name = "\0",
            Parent = Library.NotifHolder.Instance,
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8)
        })

        do
            Library.CreateColorpicker = function(Self, Data)
                local Colorpicker = {
                    Hue = 0,
                    Saturation = 0,
                    Value = 0,

                    Alpha = 0,

                    Color = Color3.fromRGB(255, 255, 255),
                    HexValue = "#FFFFFF",

                    Flag = Data.Flag,
                    IsOpen = false,

                    Items = { }
                }

                local Items = { } do
                    Items["ColorpickerButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Data.Parent.Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 20, 0, 8),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 143, 203)
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Items["ColorpickerWindow"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 1011, 0, 100),
                        Size = UDim2.new(0, 204, 0, 178),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["CurrentColor"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 8, 1, -8),
                        Size = UDim2.new(0, 14, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 143, 203)
                    })

                    Items["Checkers"] = Library:Create("ImageLabel", {
                        Name = "\0",
                        Parent = Items["CurrentColor"].Instance,
                        ScaleType = Enum.ScaleType.Tile,
                        ImageTransparency = 0.6000000238418579,
                        TileSize = UDim2.new(0, 6, 0, 6),
                        Image = "http://www.roblox.com/asset/?id=18274452449",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0
                    })

                    Items["Hue"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 8, 0, 8),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 14, 1, -38),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Hue"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }
                    })

                    Items["HueDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Hue"].Instance,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(1, 0, 0, 1),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["HueDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Color3.fromRGB(6, 7, 7)
                    })

                    Items["Alpha"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(1, 1),
                        Position = UDim2.new(1, -8, 1, -8),
                        Size = UDim2.new(1, -38, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 143, 203)
                    })

                    Items["CheckersAlpha"] = Library:Create("ImageLabel", {
                        Name = "\0",
                        Parent = Items["Alpha"].Instance,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.new(0, 6, 0, 6),
                        Image = "http://www.roblox.com/asset/?id=18274452449",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0
                    })

                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["CheckersAlpha"].Instance,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                        },
                    })

                    Items["AlphaDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Alpha"].Instance,
                        Size = UDim2.new(0, 1, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["AlphaDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Color3.fromRGB(6, 7, 7)
                    })

                    Items["Palette"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 30, 0, 8),
                        Size = UDim2.new(1, -38, 1, -38),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 143, 203)
                    })

                    Items["Saturation"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Saturation"].Instance,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                    })

                    Items["Value"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Value"].Instance,
                        Rotation = 90,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                    })

                    Items["PaletteDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(0, 1, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["PaletteDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Color3.fromRGB(6, 7, 7)
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Colorpicker.Items = Items
                end

                Colorpicker.Holder = Items["ColorpickerWindow"]

                function Colorpicker:SetVisibility(Bool)
                    Items["ColorpickerButton"].Instance.Visible = Bool
                end

                function Colorpicker:Update(IsFromAlpha)
                    local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                    Colorpicker.Color = Color3.fromHSV(Hue, Saturation, Value)
                    Colorpicker.HexValue = Colorpicker.Color:ToHex()

                    Items["ColorpickerButton"]:Tween({BackgroundColor3 = Colorpicker.Color})
                    Items["Palette"]:Tween({BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)})

                    Flags[Colorpicker.Flag] = {
                        Alpha = Colorpicker.Alpha,
                        Color = Colorpicker.Color,
                        HexValue = Colorpicker.HexValue,
                        Transparency = 1 - Colorpicker.Alpha
                    }

                    if not IsFromAlpha then
                        Items["Alpha"]:Tween({BackgroundColor3 = Colorpicker.Color})
                    end

                    Items["CurrentColor"]:Tween({BackgroundColor3 = Colorpicker.Color})
                    Items["Checkers"]:Tween({ImageTransparency = 1 - Colorpicker.Alpha})

                    if Data.Callback then
                        Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                    end
                end

                local Debounce = false
                local ColorpickerWindow = Items["ColorpickerWindow"].Instance
                local ColorpickerButton = Items["ColorpickerButton"].Instance

                local IsSettings = Data.Section and Data.Section.IsSettings

                function Colorpicker:SetOpen(Bool)
                    if Debounce then
                        return
                    end

                    Colorpicker.IsOpen = Bool

                    Debounce = true

                    if Colorpicker.IsOpen then
                        ColorpickerWindow.Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + GuiInset)

                        ColorpickerWindow.Parent = Library.Holder.Instance
                        ColorpickerWindow.Visible = true
                        Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + 10 + GuiInset)})

                        Items["ColorpickerWindow"]:FadeDescendants(true, function()
                            Debounce = false
                        end)

                        for Index, Value in Library.OpenFrames do
                            if Value ~= IsSettings then
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Colorpicker] = Colorpicker
                    else
                        Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["ColorpickerWindow"]:FadeDescendants(false, function()
                            ColorpickerWindow.Parent = Library.UnusedHolder.Instance
                            Debounce = false
                        end)

                        if Library.OpenFrames[Colorpicker] then
                            Library.OpenFrames[Colorpicker] = nil
                        end
                    end

                    local Descendants = ColorpickerWindow:GetDescendants()
                    table.insert(Descendants, ColorpickerWindow)

                    for Index, Value in Descendants do
                        if not Value.ClassName:find("UI") then
                            if IsSettings then
                                Value.ZIndex = Colorpicker.IsOpen and Library.ZIndexOrder.ColorpickerWindow + 4 or 1
                            else
                                Value.ZIndex = Colorpicker.IsOpen and Library.ZIndexOrder.ColorpickerWindow or 1
                            end
                        end
                    end
                end

                local SlidingPalette = false
                local PaletteChanged

                function Colorpicker:SlidePalette(Input)
                    if not Input or not SlidingPalette then
                        return
                    end

                    local ValueX = math.clamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                    local ValueY = math.clamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

                    Colorpicker.Saturation = ValueX
                    Colorpicker.Value = ValueY

                    local SlideX = math.clamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.99)
                    local SlideY = math.clamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.99)

                    Items["PaletteDragger"]:Tween({Position = UDim2.new(SlideX, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update()
                end

                local SlidingHue = false
                local HueChanged

                function Colorpicker:SlideHue(Input)
                    if not Input or not SlidingHue then
                        return
                    end

                    local ValueY = math.clamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)

                    local SlideY = math.clamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.99)

                    Colorpicker.Hue = ValueY

                    Items["HueDragger"]:Tween({Position = UDim2.new(0, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update()
                end

                local SlidingAlpha = false
                local AlphaChanged

                function Colorpicker:SlideAlpha(Input)
                    if not Input or not SlidingAlpha then
                        return
                    end

                    local ValueX = math.clamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)

                    Colorpicker.Alpha = ValueX

                    local SlideX = math.clamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.985)

                    Items["AlphaDragger"]:Tween({Position = UDim2.new(SlideX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update(true)
                end

                function Colorpicker:Set(Color, Alpha)
                    if type(Color) == "table" then
                        Color = Color3.fromRGB(Color[1], Color[2], Color[3])
                    elseif type(Color) == "string" then
                        Color = Color3.fromHex(Color)
                    else
                        Color = Color -- lul
                    end

                    Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                    Colorpicker.Alpha = Alpha or 0

                    local PaletteValueX = math.clamp(1 - Colorpicker.Saturation, 0, 0.99)
                    local PaletteValueY = math.clamp(1 - Colorpicker.Value, 0, 0.99)

                    local AlphaPositionX = math.clamp(Colorpicker.Alpha, 0, 0.99)

                    local HuePositionY = math.clamp(Colorpicker.Hue, 0, 0.99)

                    Items["PaletteDragger"]:Tween({Position = UDim2.new(PaletteValueX, 0, PaletteValueY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Items["HueDragger"]:Tween({Position = UDim2.new(0, 0, HuePositionY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Items["AlphaDragger"]:Tween({Position = UDim2.new(AlphaPositionX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update()
                end

                Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                    Colorpicker:SetOpen(not Colorpicker.IsOpen)
                end)

                Items["Palette"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingPalette = true

                        Colorpicker:SlidePalette(Input)

                        if PaletteChanged then
                            return
                        end

                        PaletteChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingPalette = false

                                PaletteChanged:Disconnect()
                                PaletteChanged = nil
                            end
                        end)
                    end
                end)

                Items["Hue"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingHue = true

                        Colorpicker:SlideHue(Input)

                        if HueChanged then
                            return
                        end

                        HueChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingHue = false

                                HueChanged:Disconnect()
                                HueChanged = nil
                            end
                        end)
                    end
                end)

                Items["Alpha"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingAlpha = true

                        Colorpicker:SlideAlpha(Input)

                        if AlphaChanged then
                            return
                        end

                        AlphaChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingAlpha = false

                                AlphaChanged:Disconnect()
                                AlphaChanged = nil
                            end
                        end)
                    end
                end)

                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if SlidingPalette then
                            Colorpicker:SlidePalette(Input)
                        end

                        if SlidingHue then
                            Colorpicker:SlideHue(Input)
                        end

                        if SlidingAlpha then
                            Colorpicker:SlideAlpha(Input)
                        end
                    end
                end)

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if Colorpicker.IsOpen then
                            if Items["ColorpickerWindow"]:IsMouseOverFrame() then
                                return
                            end

                            Colorpicker:SetOpen(false)
                        end
                    end
                end)

                if Data.Default then
                    Colorpicker:Set(Data.Default, Data.Alpha)
                end

                SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                    Colorpicker:Set(Value, Alpha)
                end

                return Colorpicker, Items
            end

            Library.CreateKeybind = function(Self, Data)
                local Keybind = {
                    Flag = Data.Flag,
                    IsOpen = false,

                    Key = "",
                    Mode = "",
                    Value = "",

                    Toggled = false,
                    Picking = false,

                    Items = { },
                }

                local Items = { } do
                    Items["KeyButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Data.Parent.Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = "mb2",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance
                    })

                    Library:Create("UIPadding", {
                        Parent = Items["KeyButton"].Instance,
                        PaddingRight = UDim.new(0, -1)
                    })

                    Items["KeybindWindow"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 200, 0, 50),
                        Position = UDim2.new(0, 1030, 0, 197),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        PaddingTop = UDim.new(0, 6),
                        PaddingBottom = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 6)
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Keybind.Items = Items
                end

                Keybind.Holder = Items["KeybindWindow"]

                local Debounce = false
                local KeybindWindow = Items["KeybindWindow"].Instance
                local KeyButton = Items["KeyButton"].Instance

                local IsSettings = Data.Section and Data.Section.IsSettings

                function Keybind:SetOpen(Bool)
                    if Debounce then
                        return
                    end

                    Keybind.IsOpen = Bool

                    Debounce = true

                    if Keybind.IsOpen then
                        KeybindWindow.Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + GuiInset)

                        KeybindWindow.Parent = Library.Holder.Instance
                        Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + 10 + GuiInset)})

                        Items["KeybindWindow"]:FadeDescendants(true, function()
                            Debounce = false
                        end)

                        for Index, Value in Library.OpenFrames do
                            if Value ~= IsSettings then
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Keybind] = Keybind
                    else
                        Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["KeybindWindow"]:FadeDescendants(false, function()
                            Items["KeybindWindow"].Instance.Parent = Library.UnusedHolder.Instance
                            Debounce = false
                        end)

                        if Library.OpenFrames[Keybind] then
                            Library.OpenFrames[Keybind] = nil
                        end
                    end

                    local Descendants = KeybindWindow:GetDescendants()
                    table.insert(Descendants, KeybindWindow)

                    for Index, Value in Descendants do
                        if not Value.ClassName:find("UI") then
                            if IsSettings then
                                Value.ZIndex = Keybind.IsOpen and Library.ZIndexOrder.KeybindWindow or 1
                            else
                                Value.ZIndex = Keybind.IsOpen and Library.ZIndexOrder.KeybindWindow + 1 or 1
                            end
                        end
                    end
                end

                local KeybindObject

                if Library.KeyList then
                    KeybindObject = Library.KeyList:Add("", "")
                end

                local Update = function()
                    if KeybindObject then
                        KeybindObject:Set(Data.Name, Keybind.Mode)
                        KeybindObject:SetStatus(Keybind.Toggled)

                        if Keybind.Mode == "Hold" then
                            KeybindObject:SetMode(Keybind.Toggled and "holding" or "off")
                        elseif Keybind.Mode == "Always" then
                            KeybindObject:SetMode("always on")
                        else
                            KeybindObject:SetMode(Keybind.Toggled and "toggled" or "off")
                        end
                    end
                end

                function Keybind:SetMode(Mode)
                    if Mode then
                        Keybind.Mode = Mode
                    end

                    if Keybind.Mode == "Always" then
                        Keybind.Toggled = true
                    else
                        Keybind.Toggled = false
                    end

                    Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }

                    if Data.Callback then
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end

                local ModeDropdown = Library:Dropdown({
                    Name = "mode",
                    Flag = Keybind.Flag .. "ModeDropdown",
                    Parent = Items["KeybindWindow"],
                    Items = { "Toggle", "Hold", "Always" },
                    Default = Keybind.Mode,
                    Callback = function(Value)
                        Keybind:SetMode(Value)
                    end
                })

                local ShowInKeybindsList = Library:Toggle({
                    Name = "show in keybinds list",
                    Flag = Data.Flag .. "ShowInKeybindsList",
                    Parent = Items["KeybindWindow"],
                    Default = true,
                    Callback = function(Value)
                        if KeybindObject then
                            KeybindObject:SetVis(Value)
                            Update()
                        end
                    end
                })

                if Data.Toggle then
                    Library:Toggle({
                        Name = "sync",
                        Flag = Data.Flag .. "Sync",
                        Parent = Items["KeybindWindow"],
                        Default = true,
                    })
                end

                function Keybind:Press(Bool)
                    if Keybind.Mode == "Toggle" then
                        Keybind.Toggled = not Keybind.Toggled
                    elseif Keybind.Mode == "Hold" then
                        Keybind.Toggled = Bool
                    elseif Keybind.Mode == "Always" then
                        Keybind.Toggled = true
                    end

                    Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }

                    if Data.Callback then
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end

                function Keybind:Set(Key)
                    if string.find(tostring(Key), "Enum") then
                        Keybind.Key = tostring(Key)

                        Key = Key.Name == "Backspace" and "None" or Key.Name

                        local KeyString = Keys[Keybind.Key] or string.gsub(Key, "Enum.", "") or "None"
                        local TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                        Keybind.Value = TextToDisplay
                        Items["KeyButton"].Instance.Text = TextToDisplay

                        if Keybind.Mode ~= "Always" then
                            Keybind.Toggled = false
                        end

                        Flags[Keybind.Flag] = {
                            Mode = Keybind.Mode,
                            Key = Keybind.Key,
                            Toggled = Keybind.Toggled
                        }

                        if Data.Callback then
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    elseif type(Key) == "table" then
                        local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                        Keybind.Key = tostring(Key.Key)

                        if Key.Mode then
                            Keybind:SetMode(Key.Mode)
                        else
                            Keybind:SetMode(Keybind.Mode or "Toggle")
                        end

                        local KeyString = Keys[Keybind.Key] or string.gsub(tostring(RealKey), "Enum.", "") or RealKey
                        local TextToDisplay = KeyString and string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                        TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "")

                        Keybind.Value = TextToDisplay
                        Items["KeyButton"].Instance.Text = TextToDisplay

                        if Keybind.Mode ~= "Always" then
                            Keybind.Toggled = false
                        end

                        Flags[Keybind.Flag] = {
                            Mode = Keybind.Mode,
                            Key = Keybind.Key,
                            Toggled = Keybind.Toggled
                        }

                        if Data.Callback then
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    elseif table.find({"Toggle", "Hold", "Always"}, Key) then
                        Keybind.Mode = Key
                        Keybind:SetMode(Key)
                    end

                    Keybind.Picking = false
                end

                Items["KeyButton"]:Connect("MouseButton1Click", function()
                    if Keybind.Mode ~= "Always" and Keybind.Toggled then
                        Keybind.Toggled = false
                        Flags[Keybind.Flag] = {
                            Mode = Keybind.Mode,
                            Key = Keybind.Key,
                            Toggled = false
                        }
                        if Data.Callback then
                            Library:SafeCall(Data.Callback, false)
                        end
                        Update()
                    end

                    Keybind.Picking = true

                    Items["KeyButton"].Instance.Text = ". . ."
                    Items["KeyButton"]:Tween({TextColor3 = Library.Theme.Text})

                    local InputBegan
                    InputBegan = UserInputService.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind:Set(Input.KeyCode)
                        else
                            Keybind:Set(Input.UserInputType)
                        end

                        Items["KeyButton"]:Tween({TextColor3 = Library.Theme["Inactive Text"]})

                        InputBegan:Disconnect()
                        InputBegan = nil
                    end)
                end)

                Library:Connect(UserInputService.InputBegan, function(Input, GPE)
                    if Keybind.Picking then
                        return
                    end

                    if Keybind.Value == "None" then
                        return
                    end

                    if Keybind.IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch) then
                        if not Items["KeybindWindow"]:IsMouseOverFrame() and not ModeDropdown.Items.OptionHolder:IsMouseOverFrame() then
                            Keybind:SetOpen(false)
                        end
                    end

                    if Data.Toggle and not Data.Toggle.Value then
                        return
                    end

                    if not GPE then
                        if tostring(Input.KeyCode) == Keybind.Key then
                            if Keybind.Mode == "Toggle" then
                                Keybind:Press()
                            elseif Keybind.Mode == "Hold" then
                                Keybind:Press(true)
                            elseif Keybind.Mode == "Always" then
                                Keybind:Press(true)
                            end
                        elseif tostring(Input.UserInputType) == Keybind.Key then
                            if Keybind.Mode == "Toggle" then
                                Keybind:Press()
                            elseif Keybind.Mode == "Hold" then
                                Keybind:Press(true)
                            elseif Keybind.Mode == "Always" then
                                Keybind:Press(true)
                            end
                        end
                    end
                end)

                Library:Connect(UserInputService.InputEnded, function(Input, GPE)
                    if GPE then
                        return
                    end

                    if Keybind.Value == "None" then
                        return
                    end

                    if tostring(Input.KeyCode) == Keybind.Key then
                        if Keybind.Mode == "Hold" then
                            Keybind:Press(false)
                        elseif Keybind.Mode == "Always" then
                            Keybind:Press(true)
                        end
                    elseif tostring(Input.UserInputType) == Keybind.Key then
                        if Keybind.Mode == "Hold" then
                            Keybind:Press(false)
                        elseif Keybind.Mode == "Always" then
                            Keybind:Press(true)
                        end
                    end
                end)

                Items["KeyButton"]:Connect("MouseButton2Down", function()
                    Keybind:SetOpen(not Keybind.IsOpen)
                end)

                if Data.Default then
                    Keybind:Set({
                        Mode = Data.Mode or "Toggle",
                        Key = Data.Default,
                    })
                end

                SetFlags[Keybind.Flag] = function(Value)
                    Keybind:Set(Value)
                end

                return Keybind, Items
            end

            Library.Watermark = function(Self, Params)
                Params = Params or { }

                local Watermark = {
                    Name = Params.Name or Params.name or "Watermark",
                    SubName = Params.SubName or Params.subname or "SubName",

                    Items = { }
                }

                local Items = { } do
                    Items["Watermark"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5, 0, 0, 5 + GuiInset),
                        Size = UDim2.new(0, 0, 0, 20),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["Watermark"]:MakeDraggable()

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Title"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, -10, 0, 0),
                        Size = UDim2.new(0, 0, 0, 21),
                        ZIndex = -1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["_"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -8, 1, -2),
                        Size = UDim2.new(1, 16, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Title"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Watermark.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -2),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["SubText"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Watermark"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Watermark.SubName,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["SubText"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Watermark.Items = Items
                end

                function Watermark:Center()
                    local AbsPos = Items["Watermark"].Instance.AbsolutePosition
                    Items["Watermark"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["Watermark"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                function Watermark:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Watermark:SetSubText(Text)
                    Items["SubText"].Instance.Text = tostring(Text)
                end

                function Watermark:SetVisibility(Bool)
                Items["Watermark"].Instance.Visible = Bool
                end

                Watermark:Center()

                return setmetatable(Watermark, Library)
            end

            Library.KeybindList = function(Self, Params)
                Params = Params or { }

                local KeybindList = {
                    Name = Params.Name or Params.name or 'hot<font color="rgb(126, 192, 255)">keys</font>',

                    Items = { },
                }

                Library.KeyList = KeybindList

                local Items = { } do
                    Items["KeybindList"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 20, 0.5, 0),
                        Size = UDim2.new(0, 156, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["KeybindList"]:MakeDraggable()

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Title"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, -10, 0, 0),
                        Size = UDim2.new(0, 0, 0, 21),
                        ZIndex = -1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["_"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -8, 1, -2),
                        Size = UDim2.new(1, 16, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Title"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = KeybindList.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -2),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        PaddingBottom = UDim.new(0, 7),
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 5),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    KeybindList.Items = Items
                end

                function KeybindList:Center()
                    local AbsPos = Items["KeybindList"].Instance.AbsolutePosition
                    Items["KeybindList"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["KeybindList"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                function KeybindList:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function KeybindList:SetVisibility(Bool)
                Items["KeybindList"].Instance.Visible = Bool
                end

                function KeybindList:Add(Name, Mode)
                    local NewItems = { } do
                        NewItems["NewKey"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = Items["Content"].Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 180, 0, 15),
                            BorderSizePixel = 0
                        })

                        NewItems["Holder"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = NewItems["NewKey"].Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            BorderSizePixel = 0
                        })

                        NewItems["Text"] = Library:Create("TextLabel", {
                            Name = "\0",
                            FontFace = Library.Font,
                            TextSize = Library.FontSize,
                            Parent = NewItems["Holder"].Instance,
                            TextColor3 = Library.Theme["Text"],
                            Text = "pause touch",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Size = UDim2.new(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0.5, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X
                        }):AddToTheme({TextColor3 = 'Text'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Text"].Instance
                        })

                        NewItems["Mode"] = Library:Create("TextLabel", {
                            Name = "\0",
                            FontFace = Library.Font,
                            TextSize = Library.FontSize,
                            Parent = NewItems["Holder"].Instance,
                            TextColor3 = Library.Theme["Inactive Text"],
                            Text = "always",
                            AnchorPoint = Vector2.new(1, 0.5),
                            Size = UDim2.new(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, 0, 0.5, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X
                        }):AddToTheme({TextColor3 = 'Inactive Text'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Mode"].Instance
                        })
                    end

                    task.wait()

                    local CanBeVisible = true

                    function NewItems:SetVis(Bool)
                        CanBeVisible = Bool
                    end

                    local StateId = 0

                    function NewItems:SetStatus(Bool)
                        StateId = StateId + 1
                        local Current = StateId

                        if not CanBeVisible then
                            NewItems["NewKey"].Instance.Visible = false
                            return
                        end

                        if Bool then
                            NewItems["NewKey"].Instance.Visible = true

                            NewItems["NewKey"]:Tween({Size = UDim2.new(0, 180, 0, 15), Position = UDim2.new(0, 0, 0, 0)})
                            NewItems["Text"]:Tween({TextTransparency = 0})
                            NewItems["Mode"]:Tween({TextTransparency = 0})
                        else
                            Library:Thread(function()
                                NewItems["NewKey"]:Tween({Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(-1, 0, 0, 0)})
                                local gayporn = NewItems["Text"]:Tween({TextTransparency = 1})
                                NewItems["Mode"]:Tween({TextTransparency = 1})
                                gayporn.Completed:Wait()

                                if Current ~= StateId then return end

                                NewItems["NewKey"].Instance.Visible = false
                            end)
                        end
                    end

                    function NewItems:Set(Name, Mode)
                        NewItems["Text"].Instance.Text = Name
                    end

                    function NewItems:SetMode(Mode)
                        NewItems["Mode"].Instance.Text = Mode
                    end

                    return NewItems
                end

                KeybindList:Center()

                return setmetatable(KeybindList, Library)
            end

            Library.StaffList = function(Self, Params)
                Params = Params or { }

                local StaffList = {
                    Name = Params.Name or Params.name or 'staff<font color="rgb(126, 192, 255)"> list</font>',

                    Items = { }
                }

                local Items = { } do
                    Items["StaffList"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 20, 0.7, 0),
                        Size = UDim2.new(0, 156, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["StaffList"]:MakeDraggable()

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Title"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, -10, 0, 0),
                        Size = UDim2.new(0, 0, 0, 21),
                        ZIndex = -1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["_"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -8, 1, -2),
                        Size = UDim2.new(1, 16, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Title"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = StaffList.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -2),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        PaddingBottom = UDim.new(0, 7),
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["StaffList"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 5),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    StaffList.Items = Items
                end

                function StaffList:Center()
                    local AbsPos = Items["StaffList"].Instance.AbsolutePosition
                    Items["StaffList"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["StaffList"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                function StaffList:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function StaffList:SetVisibility(Bool)
                Items["StaffList"].Instance.Visible = Bool
                end

                function StaffList:Add(Name, Rank)
                    local NewItems = { } do
                        NewItems["NewStaff"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = Items["Content"].Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 180, 0, 15),
                            BorderSizePixel = 0
                        })

                        NewItems["Text"] = Library:Create("TextLabel", {
                            Name = "\0",
                            FontFace = Library.Font,
                            TextSize = Library.FontSize,
                            Parent = NewItems["NewStaff"].Instance,
                            TextColor3 = Library.Theme["Text"],
                            Text = Name,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Size = UDim2.new(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0.5, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X
                        }):AddToTheme({TextColor3 = 'Text'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Text"].Instance
                        })

                        NewItems["Rank"] = Library:Create("TextLabel", {
                            Name = "\0",
                            FontFace = Library.Font,
                            TextSize = Library.FontSize,
                            Parent = NewItems["NewStaff"].Instance,
                            TextColor3 = Library.Theme["Inactive Text"],
                            Text = Rank,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Size = UDim2.new(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, 0, 0.5, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X
                        }):AddToTheme({TextColor3 = 'Inactive Text'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Rank"].Instance
                        })
                    end

                    function NewItems:Set(Name)
                        NewItems["Text"].Instance.Text = Name
                    end

                    function NewItems:SetRank(Rank)
                        NewItems["Rank"].Instance.Text = Rank
                    end

                    return NewItems
                end

                StaffList:Center()

                return setmetatable(StaffList, Library)
            end

            Library.TargetIndicator = function(Self, Params)
                Params = Params or { }

                local Indicator = {
                    Name = Params.Name or Params.name or "Indicator",

                    Items = { }
                }

                local Items = { } do
                    Items["TargetIndicator"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0.6829608678817749, 20, 0.6088272929191589, 0),
                        Size = UDim2.new(0, 156, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["TargetIndicator"]:MakeDraggable()

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Title"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, -10, 0, 0),
                        Size = UDim2.new(0, 0, 0, 21),
                        ZIndex = -1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["_"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -8, 1, -2),
                        Size = UDim2.new(1, 16, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Title"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Indicator.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -2),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        PaddingBottom = UDim.new(0, 7),
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["TargetIndicator"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 8),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["Main"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 235, 0, 60),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Items["Avatar"] = Library:Create("ImageLabel", {
                        Name = "\0",
                        Parent = Items["Main"].Instance,
                        Image = "rbxassetid://125055486069298",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 55, 0, 55),
                        BorderSizePixel = 0
                    })

                    Items["Other"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Main"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 68, 0, 0),
                        Size = UDim2.new(1, -68, 1, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Other"].Instance,
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["Status"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Other"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = "targeting",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Status"].Instance
                    })

                    Items["Name"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Other"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = "username",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Name"].Instance
                    })

                    Items["Healthbar"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Other"].Instance,
                        Size = UDim2.new(1, 0, 0, 3),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 4"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 4'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Healthbar"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"]
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Fill"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Healthbar"].Instance,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    })

                    Items["HealthText"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Other"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = "100/100",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["HealthText"].Instance
                    })

                    Items["Distance"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Other"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = "664ft",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Distance"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Distance"].Instance,
                        PaddingTop = UDim.new(0, 1)
                    })

                    Items["Backpack"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 235, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Library:Create("UIGridLayout", {
                        Name = "\0",
                        Parent = Items["Backpack"].Instance,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        CellSize = UDim2.new(0, 55, 0, 55)
                    })

                    Indicator.Items = Items
                end

                function Indicator:Center()
                    local AbsPos = Items["TargetIndicator"].Instance.AbsolutePosition
                    Items["TargetIndicator"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["TargetIndicator"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                function Indicator:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Indicator:SetVisibility(Bool)
                    Items["TargetIndicator"].Instance.Visible = Bool
                end

                function Indicator:SetStatus(Text, Color)
                    if typeof(Color) == "Color3" then
                        Items["Status"].Instance.Text = '<font color="rgb(' .. math.floor(Color.R * 255) .. ', ' .. math.floor(Color.G * 255) .. ', ' .. math.floor(Color.B * 255) .. ')">' .. tostring(Text) .. '</font>'
                    else
                        Items["Status"].Instance.Text = tostring(Text)
                    end
                end

                local HealthConnection = nil
                local DistanceConnection = nil

                function Indicator:ResetConnection()
                    if HealthConnection then
                        HealthConnection:Disconnect()
                        HealthConnection = nil
                    end

                    if DistanceConnection then
                        DistanceConnection:Disconnect()
                        DistanceConnection = nil
                    end
                end

                function Indicator:SetTarget(Target)
                    Indicator:ResetConnection()

                    local Name = Target.Name

                    Items["Name"].Instance.Text = Name
                    Items["Avatar"].Instance.Image = Players:GetUserThumbnailAsync(Target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

                    local function updateHealth(Health)
                        pcall(function()
                            local MaxHealth = Target.Character.Humanoid.MaxHealth
                            Health = math.max(Health, 0)
                            Items["HealthText"].Instance.Text = math.floor(Health) .. "/" .. math.floor(MaxHealth)
                            local healthAlpha = math.clamp(Health / MaxHealth, 0, 1)
                            Items["Fill"]:Tween({Size = UDim2.new(healthAlpha, 0, 1, 0)})
                        end)
                    end

                    pcall(function()
                        updateHealth(Target.Character.Humanoid.Health)
                    end)

                    HealthConnection = Target.Character.Humanoid.HealthChanged:Connect(function(Health)
                        updateHealth(Health)
                    end)

                    DistanceConnection = RunService.RenderStepped:Connect(function()
                        pcall(function()
                            if not Target or not Target.Character then return end
                            local targetRoot = Target.Character:FindFirstChild('HumanoidRootPart')
                            local targetHuman = Target.Character:FindFirstChildOfClass('Humanoid')
                            if not targetRoot or not targetHuman or targetHuman.Health <= 0 then return end
                            if not LocalPlayer.Character then return end
                            local localRoot = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
                            if not localRoot then return end
                            local Distance = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
                            Items["Distance"].Instance.Text = Distance .. " st"
                        end)
                    end)
                end

                function Indicator:ClearItems()
                    for Index, Value in Items["Backpack"].Instance:GetChildren() do
                        if Value:IsA("ImageLabel") then
                            Value:Destroy()
                        end
                    end
                end

                function Indicator:AddItem(Icon)
                    return Library:Create("ImageLabel", {
                        Name = "\0",
                        Parent = Items["Backpack"].Instance,
                        Image = Icon,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 100, 0, 100),
                        BorderSizePixel = 0
                    })
                end

                Indicator:Center()

                return setmetatable(Indicator, Library)
            end

            Library.Notification = function(Self, Params)
                local Items = { } do
                    Items["Notification"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.NotifHolder.Instance,
                        Size = UDim2.new(0, 0, 0, 22),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["Stroke1"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Items["Stroke2"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Notification"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Params.Name,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Items["TextStroke"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })
                end

                for Index, Value in Items do
                    if Value.Instance:IsA("Frame") then
                        Value.Instance.BackgroundTransparency = 1
                    elseif Value.Instance:IsA("TextLabel") then
                        Value.Instance.TextTransparency = 1
                    elseif Value.Instance:IsA("UIStroke") then
                        Value.Instance.Transparency = 1
                    end
                end

                local GetSize = function()
                    local AbsSize = Items["Notification"].Instance.AbsoluteSize
                    Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.None
                    task.wait()
                    Items["Notification"].Instance.Size = UDim2.new(0, AbsSize.X, 0, AbsSize.Y)
                    return AbsSize
                end

                local Size = GetSize()
                task.wait()
                Items["Notification"].Instance.Size = UDim2.new(0, 0, 0, Size.Y)

                local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)

                Library:Thread(function()
                    for Index, Value in Items do
                        if Value.Instance:IsA("Frame") then
                            Value:Tween({BackgroundTransparency = 0}, Info)
                        elseif Value.Instance:IsA("TextLabel") then
                            Value:Tween({TextTransparency = 0}, Info)
                        elseif Value.Instance:IsA("UIStroke") then
                            Value:Tween({Transparency = 0}, Info)
                        end
                    end

                    Items["Notification"]:Tween({Size = UDim2.new(0, Size.X, 0, Size.Y)}, Info)

                    task.delay(Params.Time + 0.1, function()
                        for Index, Value in Items do
                            if Value.Instance:IsA("Frame") then
                                Value:Tween({BackgroundTransparency = 1})
                            elseif Value.Instance:IsA("TextLabel") then
                                Value:Tween({TextTransparency = 1})
                            elseif Value.Instance:IsA("UIStroke") then
                                Value:Tween({Transparency = 1})
                            end
                        end

                        Items["Notification"]:Tween({Size = UDim2.new(0, 0, 0, 0)}, Info)
                        task.wait(0.5)
                        Items["Notification"].Instance:Destroy()
                    end)
                end)
            end

            Library.Window = function(Self, Params)
                Params = Params or { }

                local Window = {
                    Name = Params.Name or Params.name or "Window",

                    IsOpen = true,
                    Pages = { },
                    Items = { }
                }

                local Items = { } do
                    if IsMobile then
                        Library:Create("UIScale", {
                            Parent = Items["MainFrame"],
                            Scale = 0.67 -- funyn
                        })
                    end

                    Items["MainFrame"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 485, 0, 417),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Items["MainFrame"]:MakeDraggable()
                    Items["MainFrame"]:MakeResizeable(Vector2.new(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y))

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Pages"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0, 6),
                        Size = UDim2.new(1, -12, 0, 20),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Pages"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        Position = UDim2.new(0, 8, 0, 32),
                        Size = UDim2.new(1, -16, 1, -40),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Content"]
                    }):AddToTheme({BackgroundColor3 = 'Content'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 2"],
                        BorderOffset = UDim.new(0, 2)
                    }):AddToTheme({Color = 'Outline 2'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 4"],
                        BorderOffset = UDim.new(0, 3)
                    }):AddToTheme({Color = 'Outline 4'})

                    Items["Title"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        AnchorPoint = Vector2.new(1, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 2, 0, 0),
                        Size = UDim2.new(0, 0, 0, 21),
                        ZIndex = -1,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["_"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -8, 1, -2),
                        Size = UDim2.new(1, 16, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["_"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 1, 0, 0),
                        Size = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })

                    Items["ActualTitle"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Title"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Window.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -3),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ActualTitle"].Instance
                    })

                    Window.Items = Items
                end

                local Debounce = false

                function Window:SetOpen(Bool)
                    if Debounce then
                        return
                    end

                    Debounce = true

                    Window.IsOpen = Bool
                    Items["MainFrame"]:FadeDescendants(Bool, function()
                        Debounce = false
                    end)

                    for Index, Value in Library.OpenFrames do
                        Value:SetOpen(false)
                    end
                end

                function Window:Center()
                    local AbsPos = Items["MainFrame"].Instance.AbsolutePosition
                    Items["MainFrame"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["MainFrame"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                        if UserInputService:GetFocusedTextBox() then
                            return
                        end

                        Window:SetOpen(not Window.IsOpen)
                    end
                end)

                Window:Center()
                return setmetatable(Window, Library)
            end

            Library.Page = function(Self, Params)
                Params = Params or { }

                local Page = {
                    Name = Params.Name or Params.name or "Page",

                    Window = Self,
                    ColumnsData = { },
                    Items = { },
                    Active = false,
                    Debounce = false
                }

                local Items = { } do
                    Items["Inactive"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Page.Window.Items["Pages"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.new(0, 0, 1, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        PaddingRight = UDim.new(0, 7),
                        PaddingLeft = UDim.new(0, 7)
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Inactive"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = Page.Name,
                        AutomaticSize = Enum.AutomaticSize.X,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BorderSizePixel = 0,
                        ZIndex = 2
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Hide"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        Visible = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -7, 1, 4),
                        Size = UDim2.new(1, 14, 0, 4),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Hide"].Instance,
                        Size = UDim2.new(0, 1, 0, 3),
                        Position = UDim2.new(1, 0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Hide"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Size = UDim2.new(0, 1, 0, 3),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Outline 1"]
                    }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                    Items["Hide2"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -7, 1, 1),
                        Size = UDim2.new(1, 14, 0, 1),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Items["Page"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Visible = false,
                        BorderSizePixel = 0
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill,
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["LeftColumn"] = Library:Create("ScrollingFrame", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2.new(0, 0, 0, 0)
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["LeftColumn"].Instance,
                        PaddingTop = UDim.new(0, 6),
                        PaddingBottom = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 2),
                        PaddingLeft = UDim.new(0, 6)
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["LeftColumn"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["RightColumn"] = Library:Create("ScrollingFrame", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2.new(0, 0, 0, 0)
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["RightColumn"].Instance,
                        PaddingTop = UDim.new(0, 6),
                        PaddingBottom = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 2)
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["RightColumn"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Page.ColumnsData[1] = Items["LeftColumn"]
                    Page.ColumnsData[2] = Items["RightColumn"]

                    Page.Items = Items
                end

                function Page:Turn()
                    local Old = Page.Window.Current

                    if Old == Page then
                        return
                    end

                    if Page.Debounce then
                        return
                    end

                    if Old and Old.Debounce then
                        return
                    end

                    Page.Debounce = true

                    if Old then
                        Old.Items["Text"]:ChangeItemTheme({TextColor3 = "Inactive Text"})
                        Old.Items["Text"]:Tween({TextColor3 = Library.Theme["Inactive Text"]})

                        Old.Items["Hide2"]:Tween({BackgroundTransparency = 0})
                        Old.Items["Hide"].Instance.Visible = false

                        Old.Items["Inactive"].Instance.Size = UDim2.new(0, 0, 0, 21)
                        Old.Items["Text"].Instance.Position = UDim2.new(0, 0, 0.5, 0)

                        Old.Items["Page"]:FadeDescendants(false, function()
                            Old.Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                        end)
                    end

                    Items["Page"].Instance.Parent = Page.Window.Items["Content"].Instance
                    Items["Page"].Instance.Visible = true
                    Items["Page"]:FadeDescendants(true, function()
                        Page.Debounce = false
                    end)

                    Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                    Items["Text"]:Tween({TextColor3 = Library.Theme.Text})

                    Items["Hide2"]:Tween({BackgroundTransparency = 1})
                    Items["Hide"].Instance.Visible = true

                    Items["Inactive"].Instance.Size = UDim2.new(0, 0, 0, 20)
                    Items["Text"].Instance.Position = UDim2.new(0, 0, 0.5, 1)

                    Page.Window.Current = Page
                end

                Items["Inactive"]:Connect("MouseButton1Down", function()
                    Page:Turn()
                end)

                if #Page.Window.Pages == 0 then
                    Page:Turn()
                end

                table.insert(Page.Window.Pages, Page)
                return setmetatable(Page, Library)
            end

            Library.Section = function(Self, Params)
                Params = Params or { }

                local Section = {
                    Name = Params.Name or Params.name or "Section",
                    Side = Params.Side or Params.side or 1,

                    Window = Self.Window,
                    Page = Self,
                    Items = { },
                }

                local Items = { } do
                    Items["Section"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Section.Page.ColumnsData[Section.Side].Instance,
                        Size = UDim2.new(1, 0, 0, 35),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.BoldFont,
                        TextSize = Library.FontSize,
                        Parent = Items["Section"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Section.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 0, 6),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 26),
                        Size = UDim2.new(1, -8, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        PaddingBottom = UDim.new(0, 6)
                    })

                    Section.Items = Items
                end

                return setmetatable(Section, Library)
            end

            Library.MultiSection = function(Self, Params)
                Params = Params or { }

                local MultiSection = {
                    Side = Params.Side or Params.side or 1,

                    Window = Self.Window,
                    Page = Self,
                    Items = { },
                    Current = nil,
                    Sections = { }
                }

                local Items = { } do
                    Items["MultiSection"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = MultiSection.Page.ColumnsData[MultiSection.Side].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Items["Sections"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MultiSection"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Sections"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["Inline"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MultiSection"].Instance,
                        Size = UDim2.new(1, 0, 0, 35),
                        Position = UDim2.new(0, 0, 0, 23),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 7),
                        Size = UDim2.new(1, -8, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        PaddingBottom = UDim.new(0, 6)
                    })
                end

                function MultiSection:Add(Name)
                    local NewSection = {
                        Active = false,
                        Items = { },
                        Debounce = false
                    }

                    local NewItems = { } do
                        NewItems["Inactive"] = Library:Create("TextButton", {
                            Name = "\0",
                            FontFace = Library.Font,
                            TextSize = Library.FontSize,
                            Parent = Items["Sections"].Instance,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            Text = "",
                            AutoButtonColor = false,
                            AutomaticSize = Enum.AutomaticSize.X,
                            Size = UDim2.new(0, 0, 1, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            BackgroundColor3 = Library.Theme["Inline"]
                        }):AddToTheme({BackgroundColor3 = 'Inline'})

                        Library:Create("UIPadding", {
                            Name = "\0",
                            Parent = NewItems["Inactive"].Instance,
                            PaddingRight = UDim.new(0, 7),
                            PaddingLeft = UDim.new(0, 7)
                        })

                        NewItems["Text"] = Library:Create("TextLabel", {
                            Name = "\0",
                            FontFace = Library.BoldFont,
                            TextSize = Library.FontSize,
                            Parent = NewItems["Inactive"].Instance,
                            TextColor3 = Library.Theme["Inactive Text"],
                            Text = Name,
                            AutomaticSize = Enum.AutomaticSize.X,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Size = UDim2.new(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0.5, 1),
                            BorderSizePixel = 0,
                            ZIndex = 2
                        }):AddToTheme({TextColor3 = 'Inactive Text'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Text"].Instance
                        })

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Inactive"].Instance,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                            LineJoinMode = Enum.LineJoinMode.Miter,
                            Color = Library.Theme["Outline 1"]
                        }):AddToTheme({Color = 'Outline 1'})

                        Library:Create("UIStroke", {
                            Name = "\0",
                            Parent = NewItems["Inactive"].Instance,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                            LineJoinMode = Enum.LineJoinMode.Miter,
                            Color = Library.Theme["Outline 3"],
                            BorderOffset = UDim.new(0, 1)
                        }):AddToTheme({Color = 'Outline 3'})

                        NewItems["Hide"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = NewItems["Inactive"].Instance,
                            Visible = false,
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.new(0, -7, 1, 4),
                            Size = UDim2.new(1, 14, 0, 4),
                            ZIndex = 2,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Library.Theme["Inline"]
                        }):AddToTheme({BackgroundColor3 = 'Inline'})

                        Library:Create("Frame", {
                            Name = "\0",
                            Parent = NewItems["Hide"].Instance,
                            Size = UDim2.new(0, 1, 0, 3),
                            Position = UDim2.new(1, 0, 0, 0),
                            ZIndex = 2,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Library.Theme["Outline 1"]
                        }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                        Library:Create("Frame", {
                            Name = "\0",
                            Parent = NewItems["Hide"].Instance,
                            AnchorPoint = Vector2.new(1, 0),
                            Size = UDim2.new(0, 1, 0, 3),
                            ZIndex = 2,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Library.Theme["Outline 1"]
                        }):AddToTheme({BackgroundColor3 = 'Outline 1'})

                        NewItems["Hide2"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = NewItems["Inactive"].Instance,
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.new(0, -7, 1, 1),
                            Size = UDim2.new(1, 14, 0, 1),
                            ZIndex = 4,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Library.Theme["Inline"]
                        }):AddToTheme({BackgroundColor3 = 'Inline'})

                        NewItems["Content"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = Library.UnusedHolder.Instance,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            BorderSizePixel = 0
                        })

                        Library:Create("UIListLayout", {
                            Name = "\0",
                            Parent = NewItems["Content"].Instance,
                            Padding = UDim.new(0, 4),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        NewSection.Items = NewItems
                    end

                    function NewSection:Turn()
                        local Old = MultiSection.Current

                        if Old == NewSection then
                            return
                        end

                        if NewSection.Debounce then
                            return
                        end

                        if Old and Old.Debounce then
                            return
                        end

                        NewSection.Debounce = true

                        if Old then
                            Old.Items["Text"]:ChangeItemTheme({TextColor3 = "Inactive Text"})
                            Old.Items["Text"]:Tween({TextColor3 = Library.Theme["Inactive Text"]})

                            Old.Items["Hide2"]:Tween({BackgroundTransparency = 0})
                            Old.Items["Hide"].Instance.Visible = false

                            Old.Items["Inactive"].Instance.Size = UDim2.new(0, 0, 0, 21)
                            Old.Items["Text"].Instance.Position = UDim2.new(0, 0, 0.5, 0)

                            Old.Items["Content"]:FadeDescendants(false, function()
                                Old.Items["Content"].Instance.Parent = Library.UnusedHolder.Instance
                            end)
                        end

                        NewItems["Content"].Instance.Parent = Items["Content"].Instance
                        NewItems["Content"].Instance.Visible = true
                        NewItems["Content"]:FadeDescendants(true, function()
                            NewSection.Debounce = false
                        end)

                        NewItems["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                        NewItems["Text"]:Tween({TextColor3 = Library.Theme.Text})

                        NewItems["Hide2"]:Tween({BackgroundTransparency = 1})
                        NewItems["Hide"].Instance.Visible = true

                        NewItems["Inactive"].Instance.Size = UDim2.new(0, 0, 0, 20)
                        NewItems["Text"].Instance.Position = UDim2.new(0, 0, 0.5, 1)

                        MultiSection.Current = NewSection
                    end

                    NewItems["Inactive"]:Connect("MouseButton1Down", function()
                        NewSection:Turn()
                    end)

                    if #MultiSection.Sections == 0 then
                        NewSection:Turn()
                    end

                    table.insert(MultiSection.Sections, NewSection)
                    return setmetatable(NewSection, Library)
                end

                return setmetatable(MultiSection, Library)
            end

            Library.Toggle = function(Self, Params)
                Params = Params or { }

                local Toggle = {
                    Name = Params.Name or Params.name or "Toggle",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or false,
                    Callback = Params.Callback or Params.callback or function() end,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = false,
                    Items = { },
                    SettingsItem = nil,
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Toggle.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Toggle"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Parent.Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        BorderSizePixel = 0
                    })

                    Items["Indicator"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Toggle"].Instance,
                        Position = UDim2.new(0, 2, 0, 2),
                        Size = UDim2.new(0, 8, 0, 8),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Content"]
                    }):AddToTheme({BackgroundColor3 = 'Content'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Inline"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Toggle"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = Toggle.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 18, 0, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["SubElements"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Toggle"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -1, 0, 0),
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["SubElements"].Instance,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["Toggle"]:OnHover(function()
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Content"]})
                    end)

                    Toggle.Items = Items
                end

                function Toggle:Set(Bool)
                    Toggle.Value = Bool

                    if Bool then
                        Items["Inline"]:Tween({BackgroundTransparency = 0, Size = UDim2.new(1, 0, 1, 0)})
                        Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                        Items["Text"]:Tween({TextColor3 = Library.Theme.Text})
                    else
                        Items["Inline"]:Tween({BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
                        Items["Text"]:ChangeItemTheme({TextColor3 = "Inactive Text"})
                        Items["Text"]:Tween({TextColor3 = Library.Theme["Inactive Text"]})
                    end

                    if Toggle.SettingsItem then
                        Toggle.SettingsItem:SetOpen(Bool)
                    end

                    Flags[Toggle.Flag] = Bool
                    Library:SafeCall(Toggle.Callback, Bool)
                end

                function Toggle:SetVisibility(Bool)
                    Items["Toggle"].Instance.Visible = Bool
                end

                function Toggle:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Toggle:Colorpicker(Data)
                    Data = Data or { }

                    local Colorpicker = {
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Toggle.Name),
                        Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                        Callback = Data.Callback or Data.callback or function() end,
                        Alpha = Data.Alpha or Data.alpha or 0,

                        Window = Toggle.Window,
                        Page = Toggle.Page,
                        Section = Toggle.Section,
                    }

                    local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                        Parent = Items["SubElements"],
                        Page = Colorpicker.Page,
                        Section = Colorpicker.Section,
                        Flag = Colorpicker.Flag,
                        Default = Colorpicker.Default,
                        Callback = Colorpicker.Callback,
                        Alpha = Colorpicker.Alpha
                    })

                    return NewColorpicker
                end

                function Toggle:Keybind(Data)
                    Data = Data or { }

                    local Keybind = {
                        Name = Data.Name or Data.name or Toggle.Name,
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Toggle.Name),
                        Default = Data.Default or Data.default or Enum.KeyCode.E,
                        Callback = Data.Callback or Data.callback or function() end,
                        Mode = Data.Mode or Data.mode or "Toggle",

                        Window = Toggle.Window,
                        Page = Toggle.Page,
                        Section = Toggle.Section,
                    }

                    local NewKeybind, KeybindItems = Library:CreateKeybind({
                        Parent = Items["SubElements"],
                        Name = Keybind.Name,
                        Page = Keybind.Page,
                        Section = Keybind.Section,
                        Toggle = Toggle,
                        Flag = Keybind.Flag,
                        Default = Keybind.Default,
                        Mode = Keybind.Mode,
                        Callback = Keybind.Callback
                    })

                    return NewKeybind
                end

                function Toggle:Settings()
                    local Settings = {
                        IsOpen = false,
                        Items = { }
                    }

                    Items["Toggle"].Instance.AutomaticSize = Enum.AutomaticSize.Y

                    local SettingsItems = { } do
                        SettingsItems["Content"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = Items["Toggle"].Instance,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 19, 0, 19),
                            Size = UDim2.new(1, -19, 0, 0),
                            Visible = false,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.Y
                        })

                        Library:Create("UIListLayout", {
                            Name = "\0",
                            Parent = SettingsItems["Content"].Instance,
                            Padding = UDim.new(0, 4),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        Library:Create("UIPadding", {
                            Name = "\0",
                            Parent = SettingsItems["Content"].Instance,
                            PaddingBottom = UDim.new(0, 6)
                        })

                        SettingsItems["Connect"] = Library:Create("Frame", {
                            Name = "\0",
                            Parent = Items["Toggle"].Instance,
                            Position = UDim2.new(0, 5, 0, 12),
                            Size = UDim2.new(0, 2, 0, 0),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Library.Theme["Outline 2"]
                        }):AddToTheme({BackgroundColor3 = 'Outline 2'})

                        Settings.Items = SettingsItems
                    end

                    function Settings:SetOpen(Bool)
                        if Bool then
                            SettingsItems["Content"].Instance.Visible = true
                            SettingsItems["Connect"]:Tween({Size = UDim2.new(0, 2, 0, SettingsItems["Content"].Instance.AbsoluteSize.Y + 1)})
                        else
                            SettingsItems["Content"].Instance.Visible = false
                            SettingsItems["Connect"]:Tween({Size = UDim2.new(0, 2, 0, 0)})
                        end
                    end

                    Toggle.SettingsItem = Settings
                    return setmetatable(Settings, Library)
                end

                Items["Toggle"]:Connect("MouseButton1Down", function()
                    Toggle:Set(not Toggle.Value)
                end)

                Toggle:Set(Toggle.Default)

                SetFlags[Toggle.Flag] = function(Value)
                    Toggle:Set(Value)
                end

                return setmetatable(Toggle, Library)
            end

            Library.Button = function(Self, Params)
                Params = Params or { }

                local Button = {
                    Name = Params.Name or Params.name or "Button",
                    Callback = Params.Callback or Params.callback or function() end,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,
                    Items = { }
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Button.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Button"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        Size = UDim2.new(1, 0, 0, 18),
                        Active = true,
                        Selectable = true,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Items["RealButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Button"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "", -- FIX: Clear default text so it doesn't show black 'Button' text
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 2, 0, 0),
                        Size = UDim2.new(1, -4, 0, 18),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Content"]
                    }):AddToTheme({BackgroundColor3 = 'Content'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["RealButton"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Button.Name,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["RealButton"]:OnHover(function()
                        Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme["Content"]})
                    end)

                    Button.Items = Items
                end

                function Button:Press()
                    Items["RealButton"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme.Accent})
                    task.wait(0.1)
                    Items["RealButton"]:ChangeItemTheme({BackgroundColor3 = "Content"})
                    Items["RealButton"]:Tween({BackgroundColor3 = Library.Theme.Content})

                    Library:SafeCall(Button.Callback)
                end

                function Button:SetVisibility(Bool)
                    Items["Button"].Instance.Visible = Bool
                end

                function Button:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                Items["RealButton"]:Connect("MouseButton1Down", function()
                    Button:Press()
                end)

                return setmetatable(Button, Library)
            end

            Library.Slider = function(Self, Params)
                Params = Params or { }

                local Slider = {
                    Name = Params.Name or Params.name or "Slider",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or 0,
                    Min = Params.Min or Params.min or 0,
                    Max = Params.Max or Params.max or 100,
                    Callback = Params.Callback or Params.callback or function() end,
                    Decimals = Params.Decimals or Params.decimals or 0,
                    Suffix = Params.Suffix or Params.suffix or "",

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = 0,
                    Sliding = false,
                    Items = { }
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Slider.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Slider"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        BorderSizePixel = 0
                    })

                    Items["RealSlider"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Slider"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 2, 1, 0),
                        Size = UDim2.new(1, -4, 0, 3),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Content"]
                    }):AddToTheme({BackgroundColor3 = 'Content'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Items["Accent"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})

                    Items["Value"] = Library:Create("TextBox", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["RealSlider"].Instance, -- Parent to RealSlider so it doesn't move
                        TextColor3 = Library.Theme["Text"],
                        Text = "1871ft",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, -1),
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false,
                        TextEditable = true,
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Value"].Instance
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Slider"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Slider.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["RealSlider"]:OnHover(function()
                        Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Content"]})
                    end)

                    Slider.Items = Items
                end

                function Slider:Set(Value)
                    local step = Slider.Decimals
                    if step and step >= 2 and math.floor(step) == step and step <= 6 then
                        step = 10 ^ (-step)
                    end
                    Slider.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), step or Slider.Decimals)

                    Items["Accent"]:Tween({Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    
                    local formatted
                    if step and step <= 0.01 then
                        formatted = string.format("%.2f", Slider.Value)
                    elseif step and step <= 0.1 then
                        formatted = string.format("%.1f", Slider.Value)
                    else
                        formatted = string.format("%d", math.round(Slider.Value))
                    end
                    Items["Value"].Instance.Text = string.format("%s%s", formatted, Slider.Suffix)

                    Flags[Slider.Flag] = Slider.Value
                    Library:SafeCall(Slider.Callback, Slider.Value)
                end

                function Slider:SetVisibility(Bool)
                    Items["Slider"].Instance.Visible = Bool
                end

                function Slider:GetSize(Input)
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min

                    return Value
                end

                function Slider:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                local InputChanged

                Items["RealSlider"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Slider.Sliding = true

                        local Value = Slider:GetSize(Input)

                        Slider:Set(Value)

                        if InputChanged then
                            return
                        end

                        InputChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Slider.Sliding = false

                                InputChanged:Disconnect()
                                InputChanged = nil
                            end
                        end)
                    end
                end)

                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Slider.Sliding then
                            local Value = Slider:GetSize(Input)

                            Slider:Set(Value)
                        end
                    end
                end)

                Slider:Set(Slider.Default)

                Items["Value"]:Connect("FocusLost", function()
                    local num = tonumber(Items["Value"].Instance.Text:match("[-]%d+%.?%d*") or Items["Value"].Instance.Text:match("%d+%.?%d*"))
                    if num then
                        Slider:Set(num)
                    else
                        Slider:Set(Slider.Value) -- Reset text on invalid input
                    end
                end)

                SetFlags[Slider.Flag] = function(Value)
                    Slider:Set(Value)
                end

                return setmetatable(Slider, Library)
            end

            Library.Dropdown = function(Self, Params)
                Params = Params or { }

                local Dropdown = {
                    Name = Params.Name or Params.name or "Dropdown",
                    OptionItems = Params.Items or Params.items or { },
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or "",
                    Callback = Params.Callback or Params.callback or function() end,
                    Multi = Params.Multi or Params.multi or false,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = { },
                    Options = { },
                    IsOpen = false,
                    Items = { }
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Dropdown.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Dropdown"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 35),
                        BorderSizePixel = 0
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Dropdown"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Dropdown.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["RealDropdown"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Dropdown"].Instance,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 2, 1, 0),
                        Size = UDim2.new(1, -4, 0, 18),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealDropdown"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealDropdown"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Value"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["RealDropdown"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = "...",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0.5, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Value"].Instance
                    })

                    Items["OptionHolder"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 246, 0, 0),
                        Position = UDim2.new(0, 979, 0, 167),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        PaddingTop = UDim.new(0, 6),
                        PaddingBottom = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 6)
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["RealDropdown"]:OnHover(function()
                        Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Content"]})
                    end)

                    Dropdown.Items = Items
                end

                Dropdown.Holder = Items["OptionHolder"]

                function Dropdown:Set(Value)
                    if Dropdown.Multi then
                        if type(Value) ~= "table" then
                            return
                        end

                        Dropdown.Value = Value

                        for Index, Value in Value do
                            local OptionData = Dropdown.Options[Value]

                            if OptionData then
                                OptionData.IsSelected = true
                                OptionData:ToggleState("Active")
                            end
                        end

                        Flags[Dropdown.Flag] = Value
                        Items["Value"].Instance.Text = table.concat(Value, ", ")
                    else
                        if not Dropdown.Options[Value] then
                            return
                        end

                        local OptionData = Dropdown.Options[Value]

                        Dropdown.Value = Value

                        for Index, Value in Dropdown.Options do
                            if Value ~= OptionData then
                                Value.IsSelected = false
                                Value:ToggleState("Inactive")
                            else
                                Value.IsSelected = true
                                Value:ToggleState("Active")
                            end
                        end

                        Flags[Dropdown.Flag] = Value
                        Items["Value"].Instance.Text = Value
                    end

                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end

                function Dropdown:Add(Value)
                    local OptionButton = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["OptionHolder"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = Value,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.None
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = OptionButton.Instance
                    })

                    local OptionData = {
                        Button = OptionButton,
                        Text = OptionButton,
                        Name = Value,
                        IsSelected = false
                    }

                    OptionButton:OnHover(function()
                        if OptionData.IsSelected then return end
                        OptionButton:Tween({TextColor3 = Library.Theme.Text})
                    end, function()
                        if OptionData.IsSelected then return end
                        OptionButton:Tween({TextColor3 = Library.Theme["Inactive Text"]})
                    end)

                    function OptionData:ToggleState(Value)
                        if Value == "Active" then
                            OptionData.Text:ChangeItemTheme({TextColor3 = "Accent"})
                            OptionData.Text:Tween({TextColor3 = Library.Theme.Accent})
                        else
                            OptionData.Text:ChangeItemTheme({TextColor3 = "Inactive Text"})
                            OptionData.Text:Tween({TextColor3 = Library.Theme["Inactive Text"]})
                        end
                    end

                    function OptionData:Set()
                        OptionData.IsSelected = not OptionData.IsSelected

                        if Dropdown.Multi then
                            local Index = table.find(Dropdown.Value, OptionData.Name)

                            if Index then
                                table.remove(Dropdown.Value, Index)
                            else
                                table.insert(Dropdown.Value, OptionData.Name)
                            end

                            OptionData:ToggleState(Index and "Inactive" or "Active")

                            Flags[Dropdown.Flag] = Dropdown.Value

                            local TextFormat = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "..."
                            Items["Value"].Instance.Text = TextFormat
                        else
                            if OptionData.IsSelected then
                                Dropdown.Value = OptionData.Name
                                Flags[Dropdown.Flag] = OptionData.Name

                                OptionData.IsSelected = true
                                OptionData:ToggleState("Active")

                                for Index, Value in Dropdown.Options do
                                    if Value ~= OptionData then
                                        Value.IsSelected = false
                                        Value:ToggleState("Inactive")
                                    end
                                end

                                Items["Value"].Instance.Text = OptionData.Name
                            else
                                Dropdown.Value = nil
                                Flags[Dropdown.Flag] = nil

                                OptionData.IsSelected = false
                                OptionData:ToggleState("Inactive")

                                Items["Value"].Instance.Text = "..."
                            end
                        end

                        Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                    end

                    OptionData.Button:Connect("MouseButton1Down", function()
                        OptionData:Set()
                    end)

                    Dropdown.Options[OptionData.Name] = OptionData
                    return OptionData
                end

                function Dropdown:Remove(Option)
                    if Dropdown.Options[Option] then
                        Dropdown.Options[Option].Button.Instance:Destroy()
                        Dropdown.Options[Option] = nil
                    end
                end

                function Dropdown:Refresh(List)
                    for Index, Value in Dropdown.Options do
                        Dropdown:Remove(Value.Name)
                    end

                    for Index, Value in List do
                        Dropdown:Add(Value)
                    end
                end

                function Dropdown:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Dropdown:SetVisibility(Bool)
                    Items["Dropdown"].Instance.Visible = Bool
                end

                local Debounce = false
                local OptionHolder = Items["OptionHolder"].Instance
                local RealDropdown = Items["RealDropdown"].Instance

                local IsSettings = Dropdown.Section and Dropdown.Section.IsSettings

                function Dropdown:SetOpen(Bool)
                    if Debounce then
                        return
                    end

                    Dropdown.IsOpen = Bool

                    Debounce = true

                    if Dropdown.IsOpen then
                        OptionHolder.Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + GuiInset)
                        OptionHolder.Size = UDim2.new(0, RealDropdown.AbsoluteSize.X, 0, Dropdown.MaxSize)

                        OptionHolder.Parent = Library.Holder.Instance
                        Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + 10 + GuiInset)})

                        Items["OptionHolder"]:FadeDescendants(true, function()
                            Debounce = false
                        end)

                        for Index, Value in Library.OpenFrames do
                            if Value ~= IsSettings and not Params.Parent then
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Dropdown] = Dropdown
                    else
                        Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["OptionHolder"]:FadeDescendants(false, function()
                            OptionHolder.Parent = Library.UnusedHolder.Instance
                            Debounce = false
                        end)

                        if Library.OpenFrames[Dropdown] then
                            Library.OpenFrames[Dropdown] = nil
                        end
                    end

                    local Descendants = OptionHolder:GetDescendants()
                    table.insert(Descendants, OptionHolder)

                    for Index, Value in Descendants do
                        if not Value.ClassName:find("UI") then
                            if not Params.Parent then
                                Value.ZIndex = Dropdown.IsOpen and Library.ZIndexOrder.OptionHolder or 1
                            else
                                Value.ZIndex = Dropdown.IsOpen and Library.ZIndexOrder.OptionHolder + 3 or 1
                            end
                        end
                    end
                end

                Items["RealDropdown"]:Connect("MouseButton1Down", function()
                    Dropdown:SetOpen(not Dropdown.IsOpen)
                end)

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not Dropdown.IsOpen then
                            return
                        end

                        if Items["OptionHolder"]:IsMouseOverFrame() then
                            return
                        end

                        Dropdown:SetOpen(false)
                    end
                end)

                for Index, Value in Dropdown.OptionItems do
                    Dropdown:Add(Value)
                end

                Dropdown:Set(Dropdown.Default)

                SetFlags[Dropdown.Flag] = function(Value)
                    Dropdown:Set(Value)
                end

                return setmetatable(Dropdown, Library)
            end

            Library.Label = function(Self, Params)
                Params = Params or { }

                local Label = {
                    Name = Params.Name or Params.name or "Label",

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Items = { }
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Label.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Label"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        BorderSizePixel = 0
                    })

                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Label"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Label.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance
                    })

                    Items["SubElements"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Label"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["SubElements"].Instance,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Label.Items = Items
                end

                function Label:SetVisibility(Bool)
                    Items["Label"].Instance.Visible = Bool
                end

                function Label:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Label:Colorpicker(Data)
                    Data = Data or { }

                    local Colorpicker = {
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                        Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                        Callback = Data.Callback or Data.callback or function() end,
                        Alpha = Data.Alpha or Data.alpha or 0,

                        Window = Label.Window,
                        Page = Label.Page,
                        Section = Label.Section,
                    }

                    local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                        Parent = Items["SubElements"],
                        Page = Colorpicker.Page,
                        Section = Colorpicker.Section,
                        Flag = Colorpicker.Flag,
                        Default = Colorpicker.Default,
                        Callback = Colorpicker.Callback,
                        Alpha = Colorpicker.Alpha
                    })

                    return NewColorpicker
                end

                function Label:Keybind(Data)
                    Data = Data or { }

                    local Keybind = {
                        Name = Data.Name or Data.name or Label.Name,
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                        Default = Data.Default or Data.default or Enum.KeyCode.E,
                        Callback = Data.Callback or Data.callback or function() end,
                        Mode = Data.Mode or Data.mode or "Toggle",

                        Window = Label.Window,
                        Page = Label.Page,
                        Section = Label.Section,
                    }

                    local NewKeybind, KeybindItems = Library:CreateKeybind({
                        Parent = Items["SubElements"],
                        Name = Keybind.Name,
                        Page = Keybind.Page,
                        Section = Keybind.Section,
                        Flag = Keybind.Flag,
                        Default = Keybind.Default,
                        Mode = Keybind.Mode,
                        Callback = Keybind.Callback
                    })

                    return NewKeybind
                end

                Label:SetText(Label.Name)

                return setmetatable(Label, Library)
            end

            Library.Textbox = function(Self, Params)
                Params = Params or { }

                local Textbox = {
                    Name = Params.Name or Params.name or "Textbox",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or "",
                    Callback = Params.Callback or Params.callback or function() end,
                    Finished = Params.Finished or Params.finished or false,
                    Placeholder = Params.Placeholder or Params.placeholder or "",
                    Numeric = Params.Numeric or Params.numeric or false,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,
                    Value = "",

                    Items = { },
                }

                local Parent

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Textbox.Section.Items["Content"]
                end

                local Items = { } do
                    Items["Textbox"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        BorderSizePixel = 0
                    })

                    Items["Background"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Textbox"].Instance,
                        ClipsDescendants = true,
                        AnchorPoint = Vector2.new(0, 1),
                        Size = UDim2.new(1, -4, 0, 18),
                        Position = UDim2.new(0, 2, 1, 0),
                        Selectable = true,
                        Active = true,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Background"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Background"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Input"] = Library:Create("TextBox", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Background"].Instance,
                        Active = false,
                        Selectable = false,
                        AnchorPoint = Vector2.new(0, 0.5),
                        PlaceholderColor3 = Library.Theme["Inactive Text"],
                        PlaceholderText = Textbox.Placeholder,
                        Size = UDim2.new(1, -12, 0, 12),
                        TextColor3 = Library.Theme["Text"],
                        Text = "",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0.5, 0),
                        CursorPosition = -1,
                        ClearTextOnFocus = false,
                        BorderSizePixel = 0
                    }):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Input"].Instance
                    })

                    Textbox.Items = Items
                end

                function Textbox:SetVisibility(Bool)
                    Items["Textbox"].Instance.Visible = Bool
                end

                function Textbox:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Textbox:Set(Value)
                    if Textbox.Numeric then
                        if (not tonumber(Value)) and string.len(tostring(Value)) > 0 then
                            Value = Textbox.Value
                        end
                    end

                    Textbox.Value = Value
                    Items["Input"].Instance.Text = Value
                    Flags[Textbox.Flag] = Value

                    Library:SafeCall(Textbox.Callback, Value)
                end

                if Textbox.Finished then
                    Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                        if PressedEnterQuestionMark then
                            Textbox:Set(Items["Input"].Instance.Text)
                        end
                    end)
                else
                    Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                        Textbox:Set(Items["Input"].Instance.Text)
                    end)
                end

                Textbox:Set(Textbox.Default)

                SetFlags[Textbox.Flag] = function(Value)
                    Textbox:Set(Value)
                end

                return setmetatable(Textbox, Library)
            end

            Library.AddSettingPopup = function(Self, Params)
                Params = Params or { }

                local Popup = {
                    Name = Params.Name or Params.name or "Settings",
                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self.Section,
                    Items = { },
                    IsOpen = false,
                }

                local ParentContainer = (Self.Items and Self.Items["SubElements"]) and Self.Items["SubElements"].Instance or Self.Section.Items["Content"].Instance

                local Items = { } do
                    Items["SettingButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = ParentContainer,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = "⋯",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 12),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        LayoutOrder = -1 -- Appear BEFORE Keybinds (lower layout order is further left)
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["SettingButton"].Instance
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["SettingButton"].Instance,
                        PaddingRight = UDim.new(0, -1)
                    })

                    Items["SettingWindow"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 200, 0, 10),
                        Position = UDim2.new(0, 0, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["SettingWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 1"]
                    }):AddToTheme({Color = 'Outline 1'})

                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["SettingWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline 3"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline 3'})

                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["SettingWindow"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 5),
                        AutomaticSize = Enum.AutomaticSize.Y
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        PaddingBottom = UDim.new(0, 5),
                        PaddingLeft = UDim.new(0, 5),
                        PaddingRight = UDim.new(0, 5)
                    })

                    Popup.Items = Items
                end

                function Popup:SetOpen(Bool)
                    Popup.IsOpen = Bool

                    if Bool then
                        local KeyButton = Items["SettingButton"].Instance
                        Items["SettingWindow"].Instance.Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + GuiInset)
                        Items["SettingWindow"].Instance.Parent = Library.Holder.Instance

                        for _, open in Library.OpenFrames do
                            if open ~= Popup and type(open.SetOpen) == "function" then
                                open:SetOpen(false)
                            end
                        end
                        table.insert(Library.OpenFrames, Popup)

                        Items["SettingWindow"]:FadeDescendants(true)
                        
                        Items["SettingWindow"].Instance.ZIndex = Library.ZIndexOrder.KeybindWindow or 4
                        for _, v in Items["SettingWindow"].Instance:GetDescendants() do
                            if v:IsA("GuiObject") then v.ZIndex = Items["SettingWindow"].Instance.ZIndex + 1 end
                        end
                    else
                        Items["SettingWindow"]:FadeDescendants(false, function()
                            Items["SettingWindow"].Instance.Parent = Library.UnusedHolder.Instance
                        end)
                        for i, v in Library.OpenFrames do
                            if v == Popup then table.remove(Library.OpenFrames, i) end
                        end
                    end
                end

                Items["SettingButton"]:Connect("MouseButton1Click", function()
                    Popup:SetOpen(not Popup.IsOpen)
                end)

                Library:Connect(UserInputService.InputBegan, function(Input, GPE)
                    if Popup.IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch) then
                        if not Items["SettingWindow"]:IsMouseOverFrame() and not Items["SettingButton"]:IsMouseOverFrame() then
                            Popup:SetOpen(false)
                        end
                    end
                end)

                return setmetatable(Popup, Library)
            end

            Library.InitWindow = function(Self)
                local SettingsPage = Self:Page({Name = "settings"}) do
                    local ConfigsSection = SettingsPage:Section({Name = "configs", Side = 2}) do
                        local ConfigsDropdown = ConfigsSection:Dropdown({
                            Name = "configs",
                            Flag = "configs_dropdown",
                            Items = { },
                            Multi = false,
                            Callback = function(Value)
                                ConfigSelected = Value
                            end
                        })

                        ConfigsSection:Textbox({
                            Flag = "config_name",
                            Placeholder = "",
                            Callback = function(Value)
                                ConfigName = Value
                            end
                        })

                        ConfigsSection:Button({
                            Name = "create",
                            Callback = function()
                                if ConfigName then
                                    if ConfigName == "" then
                                        return
                                    end

                                    writefile(ConfigsFolder .. ConfigName .. ".json", Library:GetConfig())
                                    Library:GetConfigsList(ConfigsDropdown)

                                    Library:Notification{Name = "created config succesfully", Time = 3}
                                end
                            end
                        })

                        ConfigsSection:Button({
                            Name = "delete",
                            Callback = function()
                                if ConfigSelected then
                                    if isfile(ConfigsFolder .. ConfigSelected .. ".json") then
                                        delfile(ConfigsFolder .. ConfigSelected .. ".json")
                                        Library:GetConfigsList(ConfigsDropdown)

                                        Library:Notification{Name = "deleted config succesfully", Time = 3}
                                    end
                                end
                            end
                        })

                        ConfigsSection:Button({
                            Name = "load",
                            Callback = function()
                                if ConfigSelected then
                                    if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                        local ConfigContent = readfile(ConfigsFolder.. ConfigSelected .. ".json")
                                        local Success, Error = Library:LoadConfig(ConfigContent)

                                        if Success then
                                            Library:Notification{Name = "loaded config succesfully", Time = 3}
                                        else
                                            Library:Notification{Name = "failed to load config: ".. Error, Time = 3}
                                        end
                                    end
                                end
                            end
                        })

                        ConfigsSection:Button({
                            Name = "save",
                            Callback = function()
                                if ConfigSelected then
                                    if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                        local Success, Error = pcall(function()
                                            writefile(ConfigsFolder .. ConfigSelected .. ".json", Library:GetConfig())
                                        end)

                                        if Success then
                                            Library:Notification{Name = "saved config succesfully", Time = 3}
                                        else
                                            Library:Notification{Name = "failed to save config: ".. Error, Time = 3}
                                        end
                                    end
                                end
                            end
                        })

                        ConfigsSection:Button({
                            Name = "refresh",
                            Callback = function()
                                Library:GetConfigsList(ConfigsDropdown)
                            end
                        })

                        Library:GetConfigsList(ConfigsDropdown)
                    end

                    local ThemingSection = SettingsPage:Section({Name = "theming", Side = 1}) do
                        for Index, Value in Library.Theme do
                            ThemingSection:Label({Name = Index}):Colorpicker({
                                Name = Index,
                                Flag = Index,
                                Default = Value,
                                Callback = function(Value)
                                    Library.Theme[Index] = Value
                                    Library:ChangeTheme(Index, Value)
                                end
                            })
                        end
                    end

                    local OtherSection = SettingsPage:Section({Name = "other", Side = 2}) do
                        OtherSection:Button({
                            Name = "unload",
                            Callback = function()
                                Library:Exit()
                            end
                        })

                        OtherSection:Label({Name = "ui bind"}):Keybind({Flag = "uibind", Mode = "Toggle", Default = Enum.KeyCode.RightShift, Callback = function(Value)
                            Library.MenuKeybind = Flags["uibind"].Key
                        end})

                        OtherSection:Dropdown({
                            Name = "animation style",
                            Items = {"Linear", "Quad", "Quart", "Back", "Bounce", "Circular", "Cubic", "Elastic", "Exponential", "Sine", "Quint"},
                            Default = "Cubic",
                            Callback = function(Value)
                                Library.Animation.Style = Value
                            end
                        })

                        OtherSection:Dropdown({
                            Name = "animation direction",
                            Items = {"In", "Out", "InOut"},
                            Default = "Out",
                            Callback = function(Value)
                                Library.Animation.Direction = Value
                            end
                        })

                        OtherSection:Slider({
                            Name = "animation time",
                            Min = 0,
                            Max = 1,
                            Default = 0.25,
                            Decimals = 0.01,
                            Suffix = "s",
                            Callback = function(Value)
                                Library.Animation.Time = Value
                            end
                        })
                    end
                end
            end
        end
    end
end 

getgenv().Library = Library
return Library
