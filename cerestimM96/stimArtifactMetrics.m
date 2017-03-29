function [integralErr,slopeErr]=stimArtifactMetrics(artifactData,varargin);
    startPoint=15;
    endPoint=30;
    if ~isempty(varargin)
        startPoint=varargin{1}(1);
        endPoint=varargin{1}(2);
    end
    integralErr=sum(abs(artifactData(startPoint:endPoint)));
    slopeErr=abs(artifactData(startPoint)-artifactData(endPoint));
end