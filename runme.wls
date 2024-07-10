#!/usr/bin/env wolframscript
(* ::Package:: *)
SetDirectory[If[StringQ[NotebookDirectory[] ], NotebookDirectory[], DirectoryName[$InputFileName] ] ]

Uncompress["1:eJx1T8tuwjAQDBT1wo0/6Ac0vveKKAoNCJoDZ5NugsXGtrwbBf6edawKLlzG+5rxzMfJ/TZvWZbRVKBomkms5wLfBmF1NcR0qN6lL/fbfMC0j4Q18
PM80mkmcDR8TlexK0Ug7SKnAh5f9F0aRoGi8y5wVUp5Zvb0pVTQQ96KTn/qCULtLIPlvHad2kAIt0IN+Imu1uh1fdEtkOq0seoHggVUydForuJgbJsCLgSWTj7r7d/q6gMQGWfT
Lt7KLPp4ZPq3+qz0Iv6Yddcj3gGoDVPG"];

PacletRepositories[{
  Github -> "https://github.com/KirillBelovTest/Objects",
  Github -> "https://github.com/KirillBelovTest/Internal",
  Github -> "https://github.com/JerryI/CSocketListener" -> "dev2024",
  Github -> "https://github.com/KirillBelovTest/TCPServer",
  Github -> "https://github.com/KirillBelovTest/WebSocketHandler",
  Github -> "https://github.com/JerryI/wl-wlx" -> "master",
  Github -> "https://github.com/JerryI/wl-wljs-packages",  
  Github -> "https://github.com/JerryI/wl-misc" -> "dev"
}]

(* Here you can configure server *)
ENV = <|
    "WSPort"->8011,
    "Host"->"127.0.0.1"
|>

ENV["WAddr"] := StringTemplate["``:``"][ENV["Host"], ENV["WSPort"]]

(* TCP Server *)
<<KirillBelov`Objects`
<<KirillBelov`Internal`
<<KirillBelov`CSockets`
<<KirillBelov`TCPServer`

(* WS services *)
<<KirillBelov`WebSocketHandler`

<<JerryI`WLX`
<<JerryI`WLX`Importer`
<<JerryI`WLX`WLJS`

(* Event handling and WLJS communication *)
<<JerryI`Misc`WLJS`Transport`
<<JerryI`WLJSPM`

(**** HELPERS (used on Kernel) FOR PLOTLY and other libs *****)

WLJS`PM`Repositories[{
  Github -> "https://github.com/JerryI/wljs-interpreter" -> "dev",
  Github -> "https://github.com/JerryI/wljs-sharedlib-d3" -> "master",
  Github -> "https://github.com/JerryI/wljs-graphics-d3" -> "dev",
  Github -> "https://github.com/JerryI/wljs-plotly" -> "dev",
  Github -> "https://github.com/JerryI/Mathematica-ThreeJS-graphics-engine" -> "dev"
}]

(* import libs data *)
Map[Function[path,
    Block[{System`$RemotePackageDirectory = FileNameJoin[{"wljs_packages", FileNameSplit[path] // First}]},
        FileNameJoin[{"wljs_packages", path}] // Get // Quiet;
    ];
], WLJS`PM`Includes["kernel"] ];




(**** GENERATE STATIC PAGE *****)

(* our main file for all requests *)
App = ImportComponent["Template.wlx"];




(************************************* EXAMPLE 1 *************************************)

With[{example = Identity[
    StreamPlot[{-1 - x^2 + y, 1 + x - y^2}, {x, -3, 3}, {y, -3, 3}]
]},
    Export["Static example 1.html", App["Expression" -> example], "Text"]
]


(************************************* EXAMPLE 2 *************************************)

With[{example = Identity[
    sol = NDSolve[{D[u[t, x], t] == D[u[t, x], x, x], u[0, x] == 0, u[t, 0] == Sin[t], u[t, 5] == 0}, u, {t, 0, 10}, {x, 0, 5}]; 
    Plot3D[Evaluate[u[t, x] /. sol], {t, 0, 10}, {x, 0, 5}, PlotRange -> All, ColorFunction -> "SunsetColors"]
]},
    Export["Static example 2.html", App["Expression" -> example], "Text"]
]

(************************************* EXAMPLE 3 *************************************)

With[{example = Offload[
    aa = - 0.9;

    Graphics[{
      RGBColor[1,0,0],
    
      Line[With[{v = aa},
        Table[{x, (x-v)^2}, {x,-1,1, 0.05}]
      ]], 
    
      RGBColor[0,0,1], 
    
      Line[With[{v = aa},
        Table[{x, 2(x+v)^2}, {x,-1,1, 0.05}]
      ]],
    
      Black,
      Text[Style[aa, FontSize->14], {0, 0.5}]

    }, PlotRange->{{-1,1}, {0,2}}, Axes->True, Frame->True, ImageSize->{400,200}]  

    While[True,
        aa = aa + 0.1;
        If[aa > 0.9, aa = -0.9];
        Pause[0.1];
    ]  
]},
    Export["Dynamic example 1.html", App["Expression" -> example], "Text"]
]


(************************************* EXAMPLE 4 *************************************)

data = Table[Table[{x, Sin[x w]}, {x,-10,10,0.1}], {w, 0.1,10,0.1}];
length = Length[data];

With[{data = data, length = length},
    With[{example = Offload[
        frames = data;
        index = 1;
        frame = frames[[index]];

        Graphics[{Line[frame]}, PlotRange->{{-1,1}, {-1,1}}, Frame->True, Axes->True]

        While[True,
            index = index + 1;
            If[index > length, index = 1];
            frame = frames[[index]];
            Pause[0.01];
        ]  
    ]},
        Export["Dynamic example 2.html", App["Expression" -> example], "Text"]
    ]
]

(************************************* EXAMPLE 5 *************************************)

data = Table[NumericArray[Table[
    Table[128.0 + 128.0 {
        Sin[x + y + t],
        Cos[x + y + t],
        Cos[t]
    }, {x, -10,10,0.1}, {y, -5,5,0.1}]
], "UnsignedInteger8", "ClipAndRound"], {t,0,2Pi,0.1}];

length = Length[data];

With[{data = data, length = length},
    With[{example = Offload[
        frames = data;
        index = 1;
        frame = frames[[index]];

        Image[frame, "Byte", Magnification->10] // FrontEndVirtual;

        While[True,
            index = index + 1;
            If[index > length, index = 1];
            frame = frames[[index]];
            Pause[1/30.0];
        ]  
    ]},
        Export["Dynamic example 3.html", App["Expression" -> example], "Text"]
    ]
]


