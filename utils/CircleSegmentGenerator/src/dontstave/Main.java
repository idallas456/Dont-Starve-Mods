package dontstave;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Insets;
import java.awt.RenderingHints;
import java.awt.geom.Arc2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import javax.imageio.ImageIO;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JPanel;

public class Main {

	public static void main(String[] args) throws Exception {
		// Overall size of each image.
		int width = 128, height = 128;
		
		Set<Integer> segmentSizes = DontStarveSeasonDurationSegmentCalculator.getNecessarySegmentsInDegrees();
		segmentSizes.add(1);
		
		for(int segmentSize : segmentSizes){
			// TYPE_INT_ARGB specifies the image format: 8-bit RGBA packed into integer pixels
			BufferedImage bi = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
			CircleSegment.createCircleSegment(bi, segmentSize+2, width, height);
			ImageIO.write(bi, "PNG", new File("/home/reef/.local/share/Steam/SteamApps/common/dont_starve/mods/seasonclock/images/circlesegment_" + segmentSize + ".PNG"));
		}

	}
	
	public static class CircleSegment {
        
		/**
		 * See: http://java.comsci.us/examples/awt/geom/Arc2D.html and http://stackoverflow.com/questions/15167276/drawing-slices-of-a-circle-in-java
		 */
        public static Graphics2D createCircleSegment(BufferedImage g, int degrees, int width, int height){
        	Graphics2D g2d = (Graphics2D) g.createGraphics();
            g2d.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION, RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g2d.setRenderingHint(RenderingHints.KEY_COLOR_RENDERING, RenderingHints.VALUE_COLOR_RENDER_QUALITY);
            g2d.setRenderingHint(RenderingHints.KEY_DITHERING, RenderingHints.VALUE_DITHER_ENABLE);
            g2d.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, RenderingHints.VALUE_FRACTIONALMETRICS_ON);
            g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g2d.setRenderingHint(RenderingHints.KEY_STROKE_CONTROL, RenderingHints.VALUE_STROKE_PURE);

            int diameter = Math.min(width, height)*2;
            // x, y is the horizontal and vertical position of upper left corner of the bounding rectangle, in pixels.
            int x = -width;//((width - raidus) / 2);
            int y = 0;//(height - raidus) / 2);

            g2d.setColor(Color.WHITE);
            Arc2D arc = new Arc2D.Double(x, y, diameter, diameter, 90, -degrees, Arc2D.PIE);
            
            g2d.fill(arc);
            
            return g2d;
        }
    }
	
}
