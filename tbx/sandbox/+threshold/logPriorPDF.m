function y = logPriorPDF(th, meanThreshold, varThreshold)

    y = largeshocksv.mvnlpdf(th - meanThreshold, sqrt(varThreshold));

end