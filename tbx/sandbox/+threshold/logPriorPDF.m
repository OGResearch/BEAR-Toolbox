function y = logPriorPDF(threshold, meanThreshold, varThreshold)

    y = largeshocksv.mvnlpdf(threshold - meanThreshold, sqrt(varThreshold));

end