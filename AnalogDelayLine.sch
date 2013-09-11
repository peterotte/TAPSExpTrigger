<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="virtex4" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="XLXN_7">
            <attr value="TRUE" name="KEEP">
                <trait verilog="all:0 wsynth:1" />
                <trait vhdl="all:0 wa:1 wd:1" />
            </attr>
        </signal>
        <signal name="Delay_IN" />
        <signal name="Delay_OUT" />
        <port polarity="Input" name="Delay_IN" />
        <port polarity="Output" name="Delay_OUT" />
        <blockdef name="lut1">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="320" y1="-192" y2="-192" x1="384" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <rect width="256" x="64" y="-384" height="320" />
        </blockdef>
        <block symbolname="lut1" name="XLXI_8">
            <attr value="2" name="INIT">
                <trait editname="all:1 sch:0" />
                <trait edittrait="all:1 sch:0" />
                <trait verilog="all:0 dp:1nosynth wsynop:1 wsynth:1" />
                <trait vhdl="all:0 gm:1nosynth wa:1 wd:1" />
                <trait valuetype="BitVector 2 h" />
            </attr>
            <attr value="SLICE_X0Y0" name="LOC">
                <trait verilog="all:0 wsynth:1" />
                <trait vhdl="all:0 wa:1 wd:1" />
            </attr>
            <attr value="true" name="KEEP">
                <trait verilog="all:0 wsynth:1" />
                <trait vhdl="all:0 wa:1 wd:1" />
                <trait valuetype="Boolean" />
            </attr>
            <blockpin signalname="Delay_IN" name="I0" />
            <blockpin signalname="XLXN_7" name="O" />
        </block>
        <block symbolname="lut1" name="XLXI_9">
            <attr value="2" name="INIT">
                <trait editname="all:1 sch:0" />
                <trait edittrait="all:1 sch:0" />
                <trait verilog="all:0 dp:1nosynth wsynop:1 wsynth:1" />
                <trait vhdl="all:0 gm:1nosynth wa:1 wd:1" />
                <trait valuetype="BitVector 2 h" />
            </attr>
            <attr value="SLICE_X0Y255" name="LOC">
                <trait verilog="all:0 wsynth:1" />
                <trait vhdl="all:0 wa:1 wd:1" />
            </attr>
            <attr value="true" name="KEEP">
                <trait verilog="all:0 wsynth:1" />
                <trait vhdl="all:0 wa:1 wd:1" />
                <trait valuetype="Boolean" />
            </attr>
            <blockpin signalname="XLXN_7" name="I0" />
            <blockpin signalname="Delay_OUT" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="496" y="624" name="XLXI_8" orien="R0">
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="INIT" x="0" y="-476" type="instance" />
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="LOC" x="48" y="-428" type="instance" />
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="KEEP" x="96" y="-380" type="instance" />
        </instance>
        <instance x="1424" y="608" name="XLXI_9" orien="R0">
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="INIT" x="0" y="-476" type="instance" />
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="LOC" x="48" y="-428" type="instance" />
            <attrtext style="fontsize:28;fontname:Arial;displayformat:NAMEEQUALSVALUE" attrname="KEEP" x="96" y="-380" type="instance" />
        </instance>
        <branch name="XLXN_7">
            <wire x2="1152" y1="432" y2="432" x1="880" />
            <wire x2="1152" y1="432" y2="480" x1="1152" />
            <wire x2="1424" y1="480" y2="480" x1="1152" />
        </branch>
        <branch name="Delay_IN">
            <wire x2="496" y1="496" y2="496" x1="464" />
        </branch>
        <iomarker fontsize="28" x="464" y="496" name="Delay_IN" orien="R180" />
        <branch name="Delay_OUT">
            <wire x2="1840" y1="416" y2="416" x1="1808" />
        </branch>
        <iomarker fontsize="28" x="1840" y="416" name="Delay_OUT" orien="R0" />
    </sheet>
</drawing>