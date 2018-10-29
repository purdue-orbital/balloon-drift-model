%% Purdue Orbital 
% 
% NOAA Data
%
% 
% Created: October 24, 2018
%          Matthew Popplewell

%% Description of model
% 
% Exports wind speed and direction given inputs of altitude, latitude, and
% longitude from a pre-loaded NOAA .csv file.
% 

%% Function
function [windSpeed, windDir] = NOAAData(fileName, alt,lat, lon)
% inputs :
% alt: altitude (m)
% lat: latitude
% lon: longitude

% outputs: 
% windSpeed: wind speed (m/s)
% windDir: wind direction (degrees from N)
%% Initializations
altBars = [10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000]'; % altitudes in millibars
altMeters = -log(altBars * 100/101325) * 7000;
%% Find Nearest Altitude to NOAA Points
if alt < altMeters(length(altMeters))
    altRange = [0;altMeters(length(altMeters))]; % if less than the first value (~92.14m) set to between sea level and first
    altRangeLoc = [length(altMeters) + 1, length(altMeters)] % set beyond, will be used when parsing data set
else
    resultSort = sort(abs(alt - altMeters)); % find difference between each alt and sort by lowest
    altRangeLoc = [find(abs(alt - altMeters) == resultSort(1)), find(abs(alt - altMeters) == resultSort(2))] % location of two closest alts
    altRange = altMeters(altRangeLoc);
end

%% Parse Data for Altitude
startDir1 = (400 + (altRangeLoc(2) - 1) * 398) - 1; % starting row for csvread (upper bound, direction)
startSpd1 = (599 + (altRangeLoc(2) - 1) * 398) - 1; % starting row for csvread (upper bound, speed)
endDir1 = (597 + (altRangeLoc(2) - 1) * 398) - 1; % ending row for csvread (upper bound, direction)
endSpd1 = (796 + (altRangeLoc(2) - 1) * 398) - 1; % ending row for csvread (upper bound, speed)
startDir2 = (400 + (altRangeLoc(1) - 1) * 398) - 1; % starting row for csvread (lower bound, direction)
startSpd2 = (599 + (altRangeLoc(1) - 1) * 398) - 1; % starting row for csvread (lower bound, speed)
endDir2 = (597 + (altRangeLoc(1) - 1) * 398) - 1; % ending row for csvread (lower bound, direction)
endSpd2 = (796 + (altRangeLoc(1) - 1) * 398) - 1; % ending row for csvread (lower bound, speed)

upperBoundDirM = csvread(fileName, startDir1, 0, [startDir1, 0, endDir1, 2]); % direction data for upper bound alt range
lowerBoundDirM = csvread(fileName, startDir2, 0, [startDir2, 0, endDir2, 2]); % direction data for lower bound alt range
upperBoundSpdM = csvread(fileName, startSpd1, 0, [startSpd1, 0, endSpd1, 2]); % speed data for upper bound alt range
lowerBoundSpdM = csvread(fileName, startSpd2, 0, [startSpd2, 0, endSpd2, 2]); % speed data for lower bound alt range

%% Parse Data for Lat/Lon

%% Interpolate Data 
windSpeed = Interpolate(altRange(1), alt, altRange(2), lowerBoundSpd, upperBoundSpd);
windDir = Interpolate(altRange(1), alt, altRange(2), lowerBoundDir, upperBoundDir);