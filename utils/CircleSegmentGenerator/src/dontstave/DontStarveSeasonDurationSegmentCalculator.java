package dontstave;
import java.util.Set;
import java.util.TreeSet;

public class DontStarveSeasonDurationSegmentCalculator {
	
	/**
	 * This first calculate all of the possible combinations of days in Don't Starve and then figure out what all the different circle segment sizes are.
	 */
	public static Set<Integer> getNecessarySegmentsInDegrees(){
		Season autumn = new Season(5, 12, 20, 30, 50);
		Season winter = new Season(5, 10, 15, 22, 40);
		Season spring = new Season(5, 12, 20, 30, 50);
		Season summer = new Season(5, 10, 15, 22, 40);
		
		Set<Integer> totalLengthsFloor = new TreeSet<Integer>();
		
		for(int i=1; i < 6; i++){
			for(int x=0; x<=i; x++){
				for(int y=0; y<=x; y++){
					for(int z=0; z<=y; z++){
						int autumnDur = autumn.get(i);
						int winterDur = winter.get(x);
						int springDur = spring.get(y);
						int summerDur = summer.get(z);
						
						// I did both floor and ceiling. They end up being the exact same numbers for all the combinations of days.
						// This determines the size of the circle segment in degrees for this combination of season durations. 
						totalLengthsFloor.add((int) Math.floor(360/(autumnDur + winterDur + springDur + summerDur)));
					}
				}
			}
		}
		
		return totalLengthsFloor;
	}
	
	public static class Season {
		
		int[] array = new int[6];
		
		private int veryShortDuration;
		private int shortDuration;
		
		public Season(int veryShortDuration, int shortDuration,int defaultDuration, int longDuration, int veryLongDuration) {
			super();
			this.veryShortDuration = veryShortDuration;
			this.shortDuration = shortDuration;
			this.defaultDuration = defaultDuration;
			this.longDuration = longDuration;
			this.veryLongDuration = veryLongDuration;
			
			array[0] = 0;
			array[1] = veryShortDuration;
			array[2] = shortDuration;
			array[3] = defaultDuration;
			array[4] = longDuration;
			array[5] = veryLongDuration;
		}
		
		public int get(int index){
			return array[index];
		}
		
		public int getVeryShortDuration() {
			return veryShortDuration;
		}
		public void setVeryShortDuration(int veryShortDuration) {
			this.veryShortDuration = veryShortDuration;
		}
		public int getShortDuration() {
			return shortDuration;
		}
		public void setShortDuration(int shortDuration) {
			this.shortDuration = shortDuration;
		}
		public int getDefaultDuration() {
			return defaultDuration;
		}
		public void setDefaultDuration(int defaultDuration) {
			this.defaultDuration = defaultDuration;
		}
		public int getLongDuration() {
			return longDuration;
		}
		public void setLongDuration(int longDuration) {
			this.longDuration = longDuration;
		}
		public int getVeryLongDuration() {
			return veryLongDuration;
		}
		public void setVeryLongDuration(int veryLongDuration) {
			this.veryLongDuration = veryLongDuration;
		}
		private int defaultDuration;
		private int longDuration;
		private int veryLongDuration;
		
	}
}
