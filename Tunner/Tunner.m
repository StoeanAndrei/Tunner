function varargout = Tunner(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tunner_OpeningFcn, ...
                   'gui_OutputFcn',  @Tunner_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
 


 
function Tunner_OpeningFcn(hObject, eventdata, handles, varargin)
 
 
 
 
 

 
handles.output = hObject;
img1 = imread('unstpb.png');
axes(handles.axes6);
imshow(img1);

img2 = imread('acs.png');
axes(handles.axes7);
imshow(img2);

guidata(hObject, handles);

function varargout = Tunner_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function load1_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL>
    [filename, pathname] = uigetfile({'*.wav','WAV (*.wav)';
        '*.*','All files (*.*)'}, 'Choose an audio file');
    fullpathname = [pathname , filename];

    if filename==0
        warndlg('Audio cannot be selected!','Error');
        return 
    end

    string = sprintf('%s', filename);
    set(handles.load1, 'String', string);

    [handles.wav1,handles.fs1] = audioread(fullpathname);
    handles.wav1_original = handles.wav1;
    handles.fs1_original = handles.fs1;

    enableButtons(handles, 1);

    plotSound(handles, 1)

guidata(hObject, handles);

 
function play1_Callback(hObject, eventdata, handles)
    handles.player1 = audioplayer(handles.wav1, handles.fs1);
    play(handles.player1);
    
    plotSound(handles, 1);
    
    guidata(hObject, handles);

 
function stop1_Callback(hObject, eventdata, handles)
    stop(handles.player1);
    
    guidata(hObject, handles);

 
function pause1_Callback(hObject, eventdata, handles)
    pause(handles.player1);
    
    guidata(hObject, handles);

 
function resume1_Callback(hObject, eventdata, handles)
    resume(handles.player1);
    
    guidata(hObject, handles);

 
function play_faster1_Callback(hObject, eventdata, handles)
    handles.player1 = audioplayer(handles.wav1, handles.fs1 * 2);
    play(handles.player1);
    
    plotSoundByWav(handles, handles.wav1, handles.fs1 * 2, 1);
    
    guidata(hObject, handles);

 
function play_slower1_Callback(hObject, eventdata, handles)
    handles.player1 = audioplayer(handles.wav1, handles.fs1 / 2);
    play(handles.player1);
    
    plotSoundByWav(handles, handles.wav1, handles.fs1 / 2, 1);
    
    guidata(hObject, handles);

 
function fft1_Callback(hObject, eventdata, handles)
    figure()
     
    subplot(2,1,1);
    L = length(handles.wav1(:,1));
    
    Y = fft(handles.wav1(:,1));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    
    f = handles.fs1 * (0:(L/2))/L;
    plot(f, P1)
    title('Single-Sided Amplitude Spectrum of the Left Channel')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    
     
    subplot(2,1,2);
    L = length(handles.wav1(:,2));
    
    Y = fft(handles.wav1(:,2));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    
    f = handles.fs1 * (0:(L/2))/L;
    plot(f, P1)
    title('Single-Sided Amplitude Spectrum of the Right Channel')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

    guidata(hObject, handles);

 
function spectrogram1_Callback(hObject, eventdata, handles)
    figure()
    
    subplot(2,1,1)
    spectrogram(handles.wav1(:,1))
    title('Left Channel Spectrogram')
    
    subplot(2,1,2)
    spectrogram(handles.wav1(:,2))
    title('Right Channel Spectrogram')

    guidata(hObject, handles);


 
function no_filter1_Callback(hObject, eventdata, handles)
    handles.no_filter1.Value = 1;
    handles.high_freq1.Value = 0;
    handles.medium_freq1.Value = 0;
    handles.low_freq1.Value = 0;
    
    handles.wav1 = handles.wav1_original;
    
    plotSound(handles, 1);
    
 
    guidata(hObject, handles);

    
 
function high_freq1_Callback(hObject, eventdata, handles)
    handles.no_filter1.Value = 0;
    handles.high_freq1.Value = 1;
    handles.medium_freq1.Value = 0;
    handles.low_freq1.Value = 0;
    
    highPassFilter = designfilt('highpassiir', 'StopbandFrequency',7000, ...
    'PassbandFrequency', 8000, 'StopbandAttenuation', ...
    25, 'PassbandRipple', 1, 'SampleRate', handles.fs1, ...
    'DesignMethod', 'butter');

    handles.wav1 = handles.wav1_original;

    handles.wav1(:,1) = filter(highPassFilter, handles.wav1(:,1));
    handles.wav1(:,2) = filter(highPassFilter, handles.wav1(:,2));
    
    plotSound(handles, 1);
    
 
    guidata(hObject, handles);
    

 
function medium_freq1_Callback(hObject, eventdata, handles)
    handles.no_filter1.Value = 0;
    handles.high_freq1.Value = 0;
    handles.medium_freq1.Value = 1;
    handles.low_freq1.Value = 0;
    
    bandPassFilter = designfilt('bandpassiir', 'FilterOrder', 20, ...
    'PassbandFrequency1', 4000, 'PassbandFrequency2', ...
    7000, 'PassbandRipple', 1, 'SampleRate', handles.fs1);

    handles.wav1 = handles.wav1_original;

    handles.wav1(:,1) = filter(bandPassFilter, handles.wav1(:,1));
    handles.wav1(:,2) = filter(bandPassFilter, handles.wav1(:,2));
    
    plotSound(handles, 1);
    
 
    guidata(hObject, handles);


 
function low_freq1_Callback(hObject, eventdata, handles)
    handles.no_filter1.Value = 0;
    handles.high_freq1.Value = 0;
    handles.medium_freq1.Value = 0;
    handles.low_freq1.Value = 1;
    
    lowPassFilter = designfilt('lowpassiir', ...
    'PassbandFrequency', 4000, 'StopbandFrequency', 4500, ...
    'PassbandRipple', 1, 'StopbandAttenuation', 25, ...
    'DesignMethod', 'butter', 'SampleRate', handles.fs1);

    handles.wav1 = handles.wav1_original;

    handles.wav1(:,1) = filter(lowPassFilter, handles.wav1(:,1));
    handles.wav1(:,2) = filter(lowPassFilter, handles.wav1(:,2));
    
    plotSound(handles, 1);
    
 
    guidata(hObject, handles);


 
function load2_Callback(hObject, eventdata, handles)
 
 
 
    [filename, pathname] = uigetfile({'*.wav','WAV (*.wav)';
        '*.*','All files (*.*)'}, 'Choose an audio file');
    fullpathname = [pathname , filename];

    if filename==0
        warndlg('Audio file cannot be selected!','Error');
        return 
    end

    string = sprintf('%s', filename);
    set(handles.load2, 'String', string);
    
    [handles.wav2,handles.fs2] = audioread(fullpathname);
    handles.wav2_original = handles.wav2;
    handles.fs2_original = handles.fs2;

    enableButtons(handles, 2);

    plotSound(handles, 2)

guidata(hObject, handles);


 
function play2_Callback(hObject, eventdata, handles)
 
 
 
    handles.player2 = audioplayer(handles.wav2, handles.fs2);
    play(handles.player2);
    
    plotSound(handles, 2);
    
    guidata(hObject, handles);

 
function stop2_Callback(hObject, eventdata, handles)
 
 
 
    stop(handles.player2);
    
    guidata(hObject, handles);

 
function pause2_Callback(hObject, eventdata, handles)
 
 
 
    pause(handles.player2);
    
    guidata(hObject, handles);

 
function resume2_Callback(hObject, eventdata, handles)
 
 
 
    resume(handles.player2);
    
    guidata(hObject, handles);

 
function play_faster2_Callback(hObject, eventdata, handles)
 
 
 
    handles.player2 = audioplayer(handles.wav2, handles.fs2 * 2);
    play(handles.player2);
    
    plotSoundByWav(handles, handles.wav2, handles.fs2 * 2, 2);
    
    guidata(hObject, handles);

 
function play_slower2_Callback(hObject, eventdata, handles)
 
 
 
    handles.player2 = audioplayer(handles.wav2, handles.fs2 / 2);
    play(handles.player2);
    
    plotSoundByWav(handles, handles.wav2, handles.fs2 / 2, 2);
    
    guidata(hObject, handles);

 
function fft2_Callback(hObject, eventdata, handles)

    figure()
     
    subplot(2,1,1);
    L = length(handles.wav2(:,1));
    
    Y = fft(handles.wav2(:,1));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    
    f = handles.fs2 * (0:(L/2))/L;
    plot(f, P1)
    title('Single-Sided Amplitude Spectrum of Left Channel')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    
     
    subplot(2,1,2);
    L = length(handles.wav2(:,2));
    
    Y = fft(handles.wav2(:,2));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    
    f = handles.fs2 * (0:(L/2))/L;
    plot(f, P1)
    title('Single-Sided Amplitude Spectrum of Right Channel')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

    guidata(hObject, handles);

 
function spectrogram2_Callback(hObject, eventdata, handles)

    figure()
    
    subplot(2,1,1)
    spectrogram(handles.wav2(:,1))
    title('Left Channel Spectrogram')
    
    subplot(2,1,2)
    spectrogram(handles.wav2(:,2))
    title('Right Channel Spectrogram')

    guidata(hObject, handles);

 
function no_filter2_Callback(hObject, eventdata, handles)
 
 
 
    handles.no_filter2.Value = 1;
    handles.high_freq2.Value = 0;
    handles.medium_freq2.Value = 0;
    handles.low_freq2.Value = 0;
    
    handles.wav2 = handles.wav2_original;
    
    plotSound(handles, 2);
    
 
    guidata(hObject, handles);

function high_freq2_Callback(hObject, eventdata, handles)
 
 
 
    handles.no_filter2.Value = 0;
    handles.high_freq2.Value = 1;
    handles.medium_freq2.Value = 0;
    handles.low_freq2.Value = 0;
    
    highPassFilter = designfilt('highpassiir', 'StopbandFrequency',7000, ...
    'PassbandFrequency', 8000, 'StopbandAttenuation', ...
    25, 'PassbandRipple', 1, 'SampleRate', handles.fs2, ...
    'DesignMethod', 'butter');

    handles.wav2 = handles.wav2_original;

    handles.wav2(:,1) = filter(highPassFilter, handles.wav2(:,1));
    handles.wav2(:,2) = filter(highPassFilter, handles.wav2(:,2));
    
    plotSound(handles, 2);
    
 
    guidata(hObject, handles);


 
function medium_freq2_Callback(hObject, eventdata, handles)
 
 
 
    handles.no_filter2.Value = 0;
    handles.high_freq2.Value = 0;
    handles.medium_freq2.Value = 1;
    handles.low_freq2.Value = 0;
    
    bandPassFilter = designfilt('bandpassiir', 'FilterOrder', 20, ...
    'PassbandFrequency1', 4000, 'PassbandFrequency2', ...
    7000, 'PassbandRipple', 1, 'SampleRate', handles.fs2);

    handles.wav2 = handles.wav2_original;

    handles.wav2(:,1) = filter(bandPassFilter, handles.wav2(:,1));
    handles.wav2(:,2) = filter(bandPassFilter, handles.wav2(:,2));
    
    plotSound(handles, 2);
    
 
    guidata(hObject, handles);


 
function low_freq2_Callback(hObject, eventdata, handles)
 
 
 
    handles.no_filter2.Value = 0;
    handles.high_freq2.Value = 0;
    handles.medium_freq2.Value = 0;
    handles.low_freq2.Value = 1;
    
    lowPassFilter = designfilt('lowpassiir', ...
    'PassbandFrequency', 4000, 'StopbandFrequency', 4500, ...
    'PassbandRipple', 1, 'StopbandAttenuation', 25, ...
    'DesignMethod', 'butter', 'SampleRate', handles.fs2);

    handles.wav2 = handles.wav2_original;

    handles.wav2(:,1) = filter(lowPassFilter, handles.wav2(:,1));
    handles.wav2(:,2) = filter(lowPassFilter, handles.wav2(:,2));
    
    plotSound(handles, 2);
    
 
    guidata(hObject, handles);

   
 
function exit_Callback(hObject, eventdata, handles)

    close

    
% 
function plotSound(handles, wavNumber)
    if (wavNumber == 1)
        axes(handles.left_ch1);
        plot((0:length(handles.wav1(:,1)) - 1) * (1 / handles.fs1), handles.wav1(:,1));
    end
    if (wavNumber == 2)
        axes(handles.left_ch2);
        plot((0:length(handles.wav2(:,1)) - 1) * (1 / handles.fs2), handles.wav2(:,1));
    end
    xlabel('Time(s)');
    ylabel('Amp');

    if (wavNumber == 1)
        axes(handles.right_ch1);
        plot((0:length(handles.wav1(:,2)) - 1) * (1 / handles.fs1), handles.wav1(:,2));
    end
    if (wavNumber == 2)
        axes(handles.right_ch2);
        plot((0:length(handles.wav2(:,2)) - 1) * (1 / handles.fs2), handles.wav2(:,2));
    end
    xlabel('Time(s)');
    ylabel('Amp');

function plotSoundByWav(handles, wav, fs, wavNumber)
    if (wavNumber == 1)
        axes(handles.left_ch1);
    end
    if (wavNumber == 2)
        axes(handles.left_ch2);
    end
    plot((0:length(wav(:,1)) - 1) * (1 / fs), wav(:,1));
    xlabel('Time(s)');
    ylabel('Amp');

    if (wavNumber == 1)
        axes(handles.right_ch1);
    end
    if (wavNumber == 2)
        axes(handles.right_ch2);
    end
    plot((0:length(wav(:,2)) - 1) * (1 / fs), wav(:,2));
    xlabel('Time(s)');
    ylabel('Amp'); 

function enableButtons(handles, wavNumber)
    if (wavNumber == 1)
    	handles.play1.Enable = 'on';
        handles.play_faster1.Enable = 'on';
        handles.play_slower1.Enable = 'on';
        handles.pause1.Enable = 'on';
        handles.resume1.Enable = 'on';
    	handles.stop1.Enable = 'on';
        handles.fft1.Enable = 'on';
        handles.spectrogram1.Enable = 'on';
        handles.no_filter1.Enable = 'on';
        handles.high_freq1.Enable = 'on';
        handles.medium_freq1.Enable = 'on';
        handles.low_freq1.Enable = 'on';
        
        handles.no_filter1.Value = 1;
    end
    if (wavNumber == 2)
        handles.play2.Enable = 'on';
        handles.play_faster2.Enable = 'on';
        handles.play_slower2.Enable = 'on';
        handles.pause2.Enable = 'on';
        handles.resume2.Enable = 'on';
    	handles.stop2.Enable = 'on';
        handles.fft2.Enable = 'on';
        handles.spectrogram2.Enable = 'on';
        handles.no_filter2.Enable = 'on';
        handles.high_freq2.Enable = 'on';
        handles.medium_freq2.Enable = 'on';
        handles.low_freq2.Enable = 'on';
        
        handles.no_filter2.Value = 1;
    end
