classdef Test100 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Test_100                       matlab.ui.Figure
        secondsEditField               matlab.ui.control.NumericEditField
        RECORDINGButton                matlab.ui.control.Button
        PLAYButton                     matlab.ui.control.Button
        OneHundredTestLabel            matlab.ui.control.Label
        STOPButton                     matlab.ui.control.Button
        SAVEButton                     matlab.ui.control.Button
        LOADButton                     matlab.ui.control.Button
        COMPUTEButton                  matlab.ui.control.Button
        SHOWButtonGroup                matlab.ui.container.ButtonGroup
        DataWindowButton               matlab.ui.control.ToggleButton
        ResultWindowButton             matlab.ui.control.ToggleButton
        Panel_Time                     matlab.ui.container.Panel
        ha1                            matlab.ui.control.UIAxes
        RESULTSWINDOWPanel             matlab.ui.container.Panel
        ofapneasLabel_2                matlab.ui.control.Label
        ofphonemsLabel                 matlab.ui.control.Label
        UITable                        matlab.ui.control.Table
        graficoSTATISTICA              matlab.ui.control.UIAxes
        ComputationParametersPanel     matlab.ui.container.Panel
        ApneaFramemsLabel              matlab.ui.control.Label
        ApneaFrame                     matlab.ui.control.NumericEditField
        ApneaShiftmsLabel              matlab.ui.control.Label
        ApneaShift                     matlab.ui.control.NumericEditField
        ApneaThresholdEditFieldLabel   matlab.ui.control.Label
        ApneaThreshold                 matlab.ui.control.NumericEditField
        PhonemFrameLabel               matlab.ui.control.Label
        PhonemFrame                    matlab.ui.control.NumericEditField
        PhonemShiftEditField_2Label    matlab.ui.control.Label
        PhonemShift                    matlab.ui.control.NumericEditField
        PhonemThresholdEditFieldLabel  matlab.ui.control.Label
        PhonemThreshold                matlab.ui.control.NumericEditField
    end

    
    properties (Access = public)
        t_rec=120 ;
        fs=22050;
        nBits=16;
        stoprec=0;
        myRecording=1;
        ShowLength=1;
        mag=1.05;
        RecObj
        PlayObj
        idx
        idx_last
        uup
        lo
        bit=2
        transition
        apnea
        down_transitions=0;
        up_transitions=0;
        down_apnea=0;
        up_apnea=0;
        fs_apnea
        apnea_lengths
        breathin_lengths
        apnea_word
        multi
    end
    
    methods (Access = private)
        
        function resultsENDRECORDING = endrecording(app)
            app.stoprec = 1;
            %plot whole time history
            plot(app.ha1,(1:size(app.myRecording,1))./app.fs,app.myRecording)
            ylim(app.ha1,[-1.2 1.2]*app.mag);
            xlim(app.ha1,[0 (length(app.myRecording)-1)/app.fs]);
        end
        
        function resultsLIVERECORDING = liverecording(app)
            app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
            app.Panel_Time.Visible='on';
            app.RESULTSWINDOWPanel.Visible='off';
            app.secondsEditField.Enable = 'off';
            app.RECORDINGButton.Enable = 'off';
            app.SAVEButton.Enable = 'off';
            app.LOADButton.Enable = 'off';
            app.COMPUTEButton.Enable = 'off';
            app.stoprec = 0;
            plot(app.ha1,0,0);
            ylim(app.ha1,[-app.mag app.mag])
            xlim(app.ha1,[0 app.t_rec])
            xlabel(app.ha1,'Time (sec)')
            app.idx_last = 1;
            
            record(app.RecObj,app.t_rec);
            
            tic
            
            while toc<.1
            end
            tic
            
            while toc<(app.t_rec+0.2) && (app.stoprec~=1)
                app.myRecording = getaudiodata(app.RecObj);
                app.idx = round(toc*app.fs);
                while app.idx-app.idx_last<.1*app.fs
                    app.idx = round(toc*app.fs);
                end
                
                %plot running time history
                plot(app.ha1,(max(1,size(app.myRecording,1)-app.fs*app.ShowLength):(2^app.bit):size(app.myRecording,1))./app.fs,app.myRecording(max(1,size(app.myRecording,1)-app.fs*app.ShowLength):(2^app.bit):end));
                app.mag = max(abs(app.myRecording));
                ylim(app.ha1,[-1.2 1.2]);%*app.mag
                xlim(app.ha1,[max(0,size(app.myRecording,1)/app.fs-app.ShowLength) max(size(app.myRecording,1)/app.fs,app.ShowLength)]);
                set(app.ha1, 'box', 'on');
                ylabel(app.ha1, 'Amplitude')
                xlabel(app.ha1, 'Time (sec)')
                drawnow
                app.idx_last = app.idx;
                
            end
            if app.stoprec==1
                app.PlayObj=getplayer(app.RecObj);
                stop(app.RecObj);
            end
            
            app.PLAYButton.Enable = 'on';
            app.SAVEButton.Enable = 'on';
            app.RECORDINGButton.Enable = 'on';
            app.secondsEditField.Enable = 'on';
            app.SAVEButton.Enable = 'on';
            app.LOADButton.Enable = 'on';
            app.COMPUTEButton.Enable = 'on';
        end
        
        function resultsPLAYRECORDING = play(app)
            app.stoprec=0;
            app.secondsEditField.Enable = 'off';
            app.RECORDINGButton.Enable = 'off';
            app.SAVEButton.Enable = 'off';
            app.LOADButton.Enable = 'off';
            app.COMPUTEButton.Enable = 'off';
            playblocking(app.PlayObj)
        end
        function resultsENDPLAYRECORDING = endplay(app)
            
            app.PLAYButton.Enable = 'on';
            app.SAVEButton.Enable = 'on';
            app.RECORDINGButton.Enable = 'on';
            app.secondsEditField.Enable = 'on';
            app.SAVEButton.Enable = 'on';
            app.LOADButton.Enable = 'on';
            app.COMPUTEButton.Enable = 'on';
            
        end
        
        function results = vad_transition(app)
            data=app.myRecording;
            % z=vadg(data,fs, vadThres,flen_factor, fsh_factor)            
            app.transition = vadg(data, app.fs, app.PhonemThreshold.Value, floor(1/(app.PhonemFrame.Value/1000)), floor(1/(app.PhonemShift.Value/1000)));
        end
        
        function results = vad_apnea(app)
            data=app.myRecording;
            % z=vadg(data,fs, vadThres,flen_factor, fsh_factor)            
            app.apnea = vadg(data, app.fs, app.ApneaThreshold.Value, floor(1/(app.ApneaFrame.Value/1000)), floor(1/(app.ApneaShift.Value/1000)));
        end
        
    end
    
    methods (Access = public)
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
             screenSize = get(groot,'ScreenSize');
              screenWidth = screenSize(3);
              screenHeight = screenSize(4);
              left = screenWidth*0.1;
              bottom = screenHeight*0.1;
              width = screenWidth*0.8;
              height = screenHeight*0.8;
              drawnow;
              app.Test_100.Position = [left bottom width height]; 
            
            app.Panel_Time.Visible='on';
            
            app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
                        
            app.RESULTSWINDOWPanel.Visible='off';
            app.UITable.RowName = 'numbered';
            %             app.UITable.Visible='off';
            
            app.PLAYButton.Enable = 'off';
            app.SAVEButton.Enable = 'off';
            app.COMPUTEButton.Enable = 'off';
            
            app.PlayObj = audioplayer(app.myRecording,app.fs,app.nBits);
            app.RecObj = audiorecorder(app.fs,app.nBits,1);
            
            ylabel(app.ha1, 'Amplitude')
            xlabel(app.ha1, 'Time (sec)')
            
            app.SHOWButtonGroup.Visible='off';
        end

        % Value changed function: secondsEditField
        function secondsEditFieldValueChanged(app, event)
            
        end

        % Button pushed function: RECORDINGButton
        function RECORDINGButtonPushed(app, event)
            app.Panel_Time.Visible='on';
            app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
            
            a = app.secondsEditField.Value;
            if a == 0
                app.t_rec=120;
            else
                app.t_rec=a;
            end
            liverecording(app)
            endrecording(app)
            %fade in
            t0=0.4;
            app.myRecording(1:(app.fs*t0-1))=0;
            app.multi=1/max(abs(app.myRecording));
            app.myRecording=app.myRecording*app.multi;
        end

        % Button pushed function: STOPButton
        function STOPButtonPushed(app, event)
            if length(app.myRecording)>2
                stop(app.RecObj)
            end
            stop(app.PlayObj)
            app.stoprec=1;
        end

        % Button pushed function: SAVEButton
        function SAVEButtonPushed(app, event)
            [y,m,d,h,min,sec]=datevec(now);
            [file,path] = uiputfile([num2str(y,'%04.0f') num2str(m,'%02.0f') num2str(d,'%02.0f') '-' num2str(h,'%02.0f') ''''  num2str(min,'%02.0f') '''''' num2str(floor(sec),'%02.0f') '.wav'],'Save record');
            audiowrite([path file],app.myRecording,app.fs);
        end

        % Button pushed function: PLAYButton
        function PLAYButtonPushed(app, event)
            app.Panel_Time.Visible='on';
            app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
            
            play(app)
            endplay(app)
        end

        % Button pushed function: LOADButton
        function LOADButtonPushed(app, event)
            [y,m,d,h,min,sec]=datevec(now);
            [file,path] = uigetfile();
            [app.myRecording, app.fs]=audioread([path file]);
            %fade in
            t0=0.4;
            app.myRecording(1:(app.fs*t0-1))=0;
            app.multi=1/max(abs(app.myRecording));
            app.myRecording=app.myRecording*app.multi;
            %plot whole time history
            app.t_rec=length(app.myRecording)/app.fs;
            app.mag=max(abs(app.myRecording));
            plot(app.ha1,(1:size(app.myRecording,1))./app.fs,app.myRecording)
            ylabel(app.ha1,'Amplitude')
            xlabel(app.ha1,'Time (sec)' )
            ylim(app.ha1,[-1.2 1.2]*app.mag);
            xlim(app.ha1,[0 (length(app.myRecording)-1)/app.fs+2]);
            app.PlayObj = audioplayer(app.myRecording,app.fs,app.nBits);
            app.PLAYButton.Enable = 'on';
            app.COMPUTEButton.Enable = 'on';
            app.Panel_Time.Visible='on';
            app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
            
            
            
        end

        % Button pushed function: COMPUTEButton
        function COMPUTEButtonPushed(app, event)
            delete( findobj(app.ha1, 'type', 'line') )
            hold(app.ha1,'on');
                                 
            d = uiprogressdlg(app.Test_100,'Title','Computing Voice Statistics',...
        'Indeterminate','on');
            %do actual VAD
            vad_transition(app);
            vad_apnea(app);
            %Plot
            Tot_Time=(length(app.myRecording)-1)/app.fs;
            t_transition=linspace(0,Tot_Time,length(app.transition));
            t_apnea=linspace(0,Tot_Time,length(app.apnea));
            plot(app.ha1,(1:size(app.myRecording,1))./app.fs,app.myRecording,'blu','linewidth',1)
            plot(app.ha1,t_transition,app.transition*0.65,'yellow','linewidth',1)
            plot(app.ha1,t_apnea,app.apnea*0.85,'linewidth',1)
            ylim(app.ha1,[-1.1 1.1])
            hold(app.ha1,'off');
            legend(app.ha1,'ORIGINAL','# PHONEMS','# APNEAS')
            
            %compute #transition and apnea
            bin_apnea_starts=zeros(1,20); %initialise vector for counting time bin of apneas
            app.up_apnea=0;
            app.down_apnea=0;
            
            bin_idx_up = 0;
            bin_idx_down = 0;
            for m=2:length(app.apnea)
                if app.apnea(m)-app.apnea(m-1)==-1
                    app.down_apnea= app.down_apnea+1;
                    bin_idx_down=bin_idx_down+1;
                    bin_apnea_ends(bin_idx_down)=m;
                elseif app.apnea(m)-app.apnea(m-1)==1
                    app.up_apnea= app.up_apnea+1;
                    bin_idx_up=bin_idx_up+1;
                    bin_apnea_starts(bin_idx_up)=m;
                end
            end
            bin_apnea_starts = bin_apnea_starts(1:app.up_apnea); %cut to meaningful length
            bin_apnea_ends = bin_apnea_ends(1:app.down_apnea); %cut to meaningful length
            
            bin_transition_ends=zeros(1,300); %initialise vector for counting time bin of transitions
            bin_idx_up = 0;
            bin_idx_down = 0;
            
            app.down_transitions=0;
            for m=2:length(app.transition)
                if app.transition(m)-app.transition(m-1)==-1
                    app.down_transitions= app.down_transitions+1;
                    bin_idx_down=bin_idx_down+1;
                    bin_transition_ends(bin_idx_down)=m;
                end
            end
            bin_transition_ends=bin_transition_ends(1:app.down_transitions); %cut to meaningful length
            
            
            % compute statistics
            t_apnea_ends=t_apnea(bin_apnea_ends);
            t_apnea_starts= t_apnea(bin_apnea_starts);
            
            app.breathin_lengths = zeros(size(bin_apnea_ends));
            
            for m = 1:length(app.breathin_lengths)
                if m == 1
                    app.breathin_lengths(m)= t_apnea(bin_apnea_starts(m))-0.5;
                    
                else
                    app.breathin_lengths(m)= t_apnea(bin_apnea_starts(m))-t_apnea(bin_apnea_ends(m-1));
                end
            end
            
            app.apnea_lengths =t_apnea_ends-t_apnea_starts;
            
            t_transition_ends = t_transition(bin_transition_ends);
            app.apnea_word = zeros(size(t_apnea_ends));
            
            for n = 1:length(app.apnea_word)
                for m = 1:length(t_transition_ends)
                    if t_transition_ends(m) < t_apnea_ends(n)
                        app.apnea_word(n) = app.apnea_word(n)+1;
                    elseif t_transition_ends(m) < t_apnea_ends(n)
                        app.apnea_word(n) = app.apnea_word(n)+1;
                    end
                end
                if n ~= 1
                    app.apnea_word(n) = app.apnea_word(n)-sum(app.apnea_word(1:(n-1)));
                elseif n == length(app.apnea_word)
                    app.apnea_word(n) = app.apnea_word(n)-sum(app.apnea_word(1:(n-1)))+1;
                end
            end         
              
            
            format shortG
            %print some statistics
            app.UITable.Data = [[1:length(t_apnea_ends)]' round(app.apnea_lengths',2) round(app.apnea_word') round(app.apnea_word./app.apnea_lengths,2)'];
            app.ofphonemsLabel.Text= sprintf('TOTAL PHONEMS=%d', app.down_transitions); %on statistics results tab
            app.ofapneasLabel_2.Text= sprintf('TOTAL APNEAS=%d', app.down_apnea); %on statistics results tab
            
            bar(app.graficoSTATISTICA,round(app.apnea_lengths,2),0.3)        
            title(app.graficoSTATISTICA,'APNEA DURATIONS & PHONEMS FREQUENCY')
            xlabel(app.graficoSTATISTICA,'Apnea Number')
            
            yyaxis(app.graficoSTATISTICA, 'left')
            ylabel(app.graficoSTATISTICA,'Apnea Duration [seconds]')
            ylim(app.graficoSTATISTICA,[0 max(app.apnea_lengths)+2])
            grid(app.graficoSTATISTICA,'on')
            
            yyaxis(app.graficoSTATISTICA, 'right')
            bar(app.graficoSTATISTICA,round(app.apnea_word./app.apnea_lengths,2),0.15)
            ylabel(app.graficoSTATISTICA,'Phonems Frequency')
            ylim(app.graficoSTATISTICA,[0 max(app.apnea_lengths)+2])
            
            legend(app.graficoSTATISTICA,'Apnea Lengths','Phonems Frequency')
            
           
            % close the dialog box
            close(d);
            %reset counters
            app.down_apnea=0;
            app.down_transitions=0;
            
            app.SHOWButtonGroup.Visible='on';
            
        end

        % Selection changed function: SHOWButtonGroup
        function SHOWButtonGroupSelectionChanged(app, event)
            selectedButton = app.SHOWButtonGroup.SelectedObject;
            if selectedButton == app.DataWindowButton
                app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
                app.Panel_Time.Visible='on';
                app.RESULTSWINDOWPanel.Visible='off';
            elseif selectedButton == app.ResultWindowButton
                app.RESULTSWINDOWPanel.Position = app.Panel_Time.Position;
                app.Panel_Time.Visible='off';
                app.RESULTSWINDOWPanel.Visible='on';
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Test_100
            app.Test_100 = uifigure;
            app.Test_100.Color = [0.9412 0.9412 0.9412];
            app.Test_100.Position = [100 100 834 562];
            app.Test_100.Name = 'Test100';

            % Create secondsEditField
            app.secondsEditField = uieditfield(app.Test_100, 'numeric');
            app.secondsEditField.ValueChangedFcn = createCallbackFcn(app, @secondsEditFieldValueChanged, true);
            app.secondsEditField.HorizontalAlignment = 'center';
            app.secondsEditField.FontName = 'Gotham Book';
            app.secondsEditField.FontWeight = 'bold';
            app.secondsEditField.FontColor = [1 1 1];
            app.secondsEditField.BackgroundColor = [0.4 0.4 0.4];
            app.secondsEditField.Position = [124 471 44 30];
            app.secondsEditField.Value = 30;

            % Create RECORDINGButton
            app.RECORDINGButton = uibutton(app.Test_100, 'push');
            app.RECORDINGButton.ButtonPushedFcn = createCallbackFcn(app, @RECORDINGButtonPushed, true);
            app.RECORDINGButton.BackgroundColor = [0.4 0.4 0.4];
            app.RECORDINGButton.FontName = 'Gotham';
            app.RECORDINGButton.FontWeight = 'bold';
            app.RECORDINGButton.FontColor = [1 1 1];
            app.RECORDINGButton.Position = [8 471 109 30];
            app.RECORDINGButton.Text = 'RECORDING';

            % Create PLAYButton
            app.PLAYButton = uibutton(app.Test_100, 'push');
            app.PLAYButton.ButtonPushedFcn = createCallbackFcn(app, @PLAYButtonPushed, true);
            app.PLAYButton.BackgroundColor = [0.4 0.4 0.4];
            app.PLAYButton.FontName = 'Gotham';
            app.PLAYButton.FontWeight = 'bold';
            app.PLAYButton.FontColor = [1 1 1];
            app.PLAYButton.Position = [7 396 161 30];
            app.PLAYButton.Text = 'PLAY';

            % Create OneHundredTestLabel
            app.OneHundredTestLabel = uilabel(app.Test_100);
            app.OneHundredTestLabel.BackgroundColor = [0.302 0.302 0.302];
            app.OneHundredTestLabel.HorizontalAlignment = 'center';
            app.OneHundredTestLabel.FontName = 'Gotham';
            app.OneHundredTestLabel.FontSize = 36;
            app.OneHundredTestLabel.FontColor = [1 1 1];
            app.OneHundredTestLabel.Position = [1 517 834 46];
            app.OneHundredTestLabel.Text = 'One Hundred Test';

            % Create STOPButton
            app.STOPButton = uibutton(app.Test_100, 'push');
            app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
            app.STOPButton.BackgroundColor = [0.4 0.4 0.4];
            app.STOPButton.FontName = 'Gotham';
            app.STOPButton.FontWeight = 'bold';
            app.STOPButton.FontColor = [1 1 1];
            app.STOPButton.Position = [7 434 161 30];
            app.STOPButton.Text = 'STOP';

            % Create SAVEButton
            app.SAVEButton = uibutton(app.Test_100, 'push');
            app.SAVEButton.ButtonPushedFcn = createCallbackFcn(app, @SAVEButtonPushed, true);
            app.SAVEButton.BackgroundColor = [1 1 1];
            app.SAVEButton.FontName = 'Gotham';
            app.SAVEButton.FontWeight = 'bold';
            app.SAVEButton.FontColor = [0.149 0.149 0.149];
            app.SAVEButton.Position = [9 525 71 30];
            app.SAVEButton.Text = 'SAVE';

            % Create LOADButton
            app.LOADButton = uibutton(app.Test_100, 'push');
            app.LOADButton.ButtonPushedFcn = createCallbackFcn(app, @LOADButtonPushed, true);
            app.LOADButton.BackgroundColor = [1 1 1];
            app.LOADButton.FontName = 'Gotham';
            app.LOADButton.FontWeight = 'bold';
            app.LOADButton.FontColor = [0.149 0.149 0.149];
            app.LOADButton.Position = [88 525 71 30];
            app.LOADButton.Text = 'LOAD';

            % Create COMPUTEButton
            app.COMPUTEButton = uibutton(app.Test_100, 'push');
            app.COMPUTEButton.ButtonPushedFcn = createCallbackFcn(app, @COMPUTEButtonPushed, true);
            app.COMPUTEButton.BackgroundColor = [1 1 0];
            app.COMPUTEButton.FontName = 'Gotham';
            app.COMPUTEButton.FontWeight = 'bold';
            app.COMPUTEButton.FontColor = [0.149 0.149 0.149];
            app.COMPUTEButton.Position = [9 341 159 30];
            app.COMPUTEButton.Text = 'COMPUTE';

            % Create SHOWButtonGroup
            app.SHOWButtonGroup = uibuttongroup(app.Test_100);
            app.SHOWButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SHOWButtonGroupSelectionChanged, true);
            app.SHOWButtonGroup.ForegroundColor = [0.149 0.149 0.149];
            app.SHOWButtonGroup.Title = 'SHOW:';
            app.SHOWButtonGroup.BackgroundColor = [0.8 0.8 0.8];
            app.SHOWButtonGroup.FontName = 'Gotham';
            app.SHOWButtonGroup.FontWeight = 'bold';
            app.SHOWButtonGroup.Position = [12 21 156 112];

            % Create DataWindowButton
            app.DataWindowButton = uitogglebutton(app.SHOWButtonGroup);
            app.DataWindowButton.Text = 'Data Window';
            app.DataWindowButton.BackgroundColor = [0 0.451 0.7412];
            app.DataWindowButton.FontName = 'Gotham';
            app.DataWindowButton.FontWeight = 'bold';
            app.DataWindowButton.FontColor = [1 1 1];
            app.DataWindowButton.Position = [13 53 134 30];
            app.DataWindowButton.Value = true;

            % Create ResultWindowButton
            app.ResultWindowButton = uitogglebutton(app.SHOWButtonGroup);
            app.ResultWindowButton.Text = 'Result Window';
            app.ResultWindowButton.BackgroundColor = [1 0.302 0.4];
            app.ResultWindowButton.FontName = 'Gotham';
            app.ResultWindowButton.FontWeight = 'bold';
            app.ResultWindowButton.FontColor = [1 1 1];
            app.ResultWindowButton.Position = [13 11 134 32];

            % Create Panel_Time
            app.Panel_Time = uipanel(app.Test_100);
            app.Panel_Time.ForegroundColor = [0.902 0.902 0.902];
            app.Panel_Time.BorderType = 'none';
            app.Panel_Time.TitlePosition = 'centertop';
            app.Panel_Time.BackgroundColor = [0 0.451 0.7412];
            app.Panel_Time.FontName = 'Gotham';
            app.Panel_Time.FontWeight = 'bold';
            app.Panel_Time.FontSize = 22;
            app.Panel_Time.Position = [184 11 651 507];

            % Create ha1
            app.ha1 = uiaxes(app.Panel_Time);
            title(app.ha1, 'DATA WINDOW')
            xlabel(app.ha1, 'Time (sec)')
            ylabel(app.ha1, 'Amplitude')
            app.ha1.AmbientLightColor = [0.902 0.902 0.8];
            app.ha1.PlotBoxAspectRatio = [1 0.750362844702467 0.750362844702467];
            app.ha1.FontName = 'Gotham';
            app.ha1.FontSize = 22;
            app.ha1.MinorGridLineStyle = '--';
            app.ha1.GridColor = [0.902 0.902 0.902];
            app.ha1.MinorGridColor = [0.902 0.902 0.902];
            app.ha1.Box = 'on';
            app.ha1.XColor = [0.149 0.149 0.149];
            app.ha1.YColor = [0.149 0.149 0.149];
            app.ha1.ZColor = [0.149 0.149 0.149];
            app.ha1.Color = [0.4 0.4 0.4];
            app.ha1.XGrid = 'on';
            app.ha1.YGrid = 'on';
            app.ha1.BackgroundColor = [0 0.451 0.7412];
            app.ha1.Position = [1 1 651 507];

            % Create RESULTSWINDOWPanel
            app.RESULTSWINDOWPanel = uipanel(app.Test_100);
            app.RESULTSWINDOWPanel.ForegroundColor = [0.149 0.149 0.149];
            app.RESULTSWINDOWPanel.TitlePosition = 'centertop';
            app.RESULTSWINDOWPanel.Title = 'RESULTS WINDOW';
            app.RESULTSWINDOWPanel.BackgroundColor = [1 0.302 0.4];
            app.RESULTSWINDOWPanel.FontName = 'Gotham';
            app.RESULTSWINDOWPanel.FontWeight = 'bold';
            app.RESULTSWINDOWPanel.FontSize = 22;
            app.RESULTSWINDOWPanel.Position = [184 11 651 507];

            % Create ofapneasLabel_2
            app.ofapneasLabel_2 = uilabel(app.RESULTSWINDOWPanel);
            app.ofapneasLabel_2.BackgroundColor = [0.8 0.8 0.8];
            app.ofapneasLabel_2.HorizontalAlignment = 'center';
            app.ofapneasLabel_2.FontName = 'Gotham';
            app.ofapneasLabel_2.FontSize = 20;
            app.ofapneasLabel_2.FontColor = [0.149 0.149 0.149];
            app.ofapneasLabel_2.Position = [58 416 236 46];
            app.ofapneasLabel_2.Text = '# of apneas';

            % Create ofphonemsLabel
            app.ofphonemsLabel = uilabel(app.RESULTSWINDOWPanel);
            app.ofphonemsLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ofphonemsLabel.HorizontalAlignment = 'center';
            app.ofphonemsLabel.FontName = 'Gotham';
            app.ofphonemsLabel.FontSize = 20;
            app.ofphonemsLabel.FontColor = [0.149 0.149 0.149];
            app.ofphonemsLabel.Position = [325 416 236 45];
            app.ofphonemsLabel.Text = '# of phonems';

            % Create UITable
            app.UITable = uitable(app.RESULTSWINDOWPanel);
            app.UITable.ColumnName = {'Apnea number'; 'Lenght'; 'Number of Phonems'; 'Frequency [NumOfPhonems/Length]'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = [true false true false];
            app.UITable.FontName = 'Gotham';
            app.UITable.FontSize = 20;
            app.UITable.Position = [10 250 630 129];

            % Create graficoSTATISTICA
            app.graficoSTATISTICA = uiaxes(app.RESULTSWINDOWPanel);
            title(app.graficoSTATISTICA, 'Title')
            xlabel(app.graficoSTATISTICA, 'X')
            ylabel(app.graficoSTATISTICA, 'Y')
            app.graficoSTATISTICA.PlotBoxAspectRatio = [1 0.248939179632249 0.248939179632249];
            app.graficoSTATISTICA.FontName = 'Gotham';
            app.graficoSTATISTICA.FontSize = 14;
            app.graficoSTATISTICA.Box = 'on';
            app.graficoSTATISTICA.XGrid = 'on';
            app.graficoSTATISTICA.YGrid = 'on';
            app.graficoSTATISTICA.Position = [10 10 630 208];

            % Create ComputationParametersPanel
            app.ComputationParametersPanel = uipanel(app.Test_100);
            app.ComputationParametersPanel.Title = 'Computation Parameters';
            app.ComputationParametersPanel.BackgroundColor = [0.8 0.8 0.8];
            app.ComputationParametersPanel.FontWeight = 'bold';
            app.ComputationParametersPanel.Position = [12 167 156 175];

            % Create ApneaFramemsLabel
            app.ApneaFramemsLabel = uilabel(app.ComputationParametersPanel);
            app.ApneaFramemsLabel.HorizontalAlignment = 'right';
            app.ApneaFramemsLabel.Position = [1 123 104 22];
            app.ApneaFramemsLabel.Text = 'Apnea Frame [ms]';

            % Create ApneaFrame
            app.ApneaFrame = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.ApneaFrame.Position = [112 123 40 22];
            app.ApneaFrame.Value = 40;

            % Create ApneaShiftmsLabel
            app.ApneaShiftmsLabel = uilabel(app.ComputationParametersPanel);
            app.ApneaShiftmsLabel.HorizontalAlignment = 'right';
            app.ApneaShiftmsLabel.Position = [1 102 94 22];
            app.ApneaShiftmsLabel.Text = 'Apnea Shift [ms]';

            % Create ApneaShift
            app.ApneaShift = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.ApneaShift.Position = [112 102 40 22];
            app.ApneaShift.Value = 5;

            % Create ApneaThresholdEditFieldLabel
            app.ApneaThresholdEditFieldLabel = uilabel(app.ComputationParametersPanel);
            app.ApneaThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.ApneaThresholdEditFieldLabel.Position = [2 81 97 22];
            app.ApneaThresholdEditFieldLabel.Text = 'Apnea Threshold';

            % Create ApneaThreshold
            app.ApneaThreshold = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.ApneaThreshold.Position = [112 81 40 22];
            app.ApneaThreshold.Value = 0.1;

            % Create PhonemFrameLabel
            app.PhonemFrameLabel = uilabel(app.ComputationParametersPanel);
            app.PhonemFrameLabel.HorizontalAlignment = 'right';
            app.PhonemFrameLabel.Position = [2 48 88 22];
            app.PhonemFrameLabel.Text = 'Phonem Frame';

            % Create PhonemFrame
            app.PhonemFrame = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.PhonemFrame.Position = [111 48 40 22];
            app.PhonemFrame.Value = 15;

            % Create PhonemShiftEditField_2Label
            app.PhonemShiftEditField_2Label = uilabel(app.ComputationParametersPanel);
            app.PhonemShiftEditField_2Label.HorizontalAlignment = 'right';
            app.PhonemShiftEditField_2Label.Position = [1 27 78 22];
            app.PhonemShiftEditField_2Label.Text = 'Phonem Shift';

            % Create PhonemShift
            app.PhonemShift = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.PhonemShift.Position = [111 27 40 22];
            app.PhonemShift.Value = 1.5;

            % Create PhonemThresholdEditFieldLabel
            app.PhonemThresholdEditFieldLabel = uilabel(app.ComputationParametersPanel);
            app.PhonemThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.PhonemThresholdEditFieldLabel.Position = [1 6 107 22];
            app.PhonemThresholdEditFieldLabel.Text = 'Phonem Threshold';

            % Create PhonemThreshold
            app.PhonemThreshold = uieditfield(app.ComputationParametersPanel, 'numeric');
            app.PhonemThreshold.Position = [111 6 40 22];
            app.PhonemThreshold.Value = 0.9;
        end
    end

    methods (Access = public)

        % Construct app
        function app = Test100

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Test_100)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Test_100)
        end
    end
end

