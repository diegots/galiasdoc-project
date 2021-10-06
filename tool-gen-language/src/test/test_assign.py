import unittest

from app.constants import *
from app.assign import assign_words_to_regions_geometric


class TestAssignWordsToRegions(unittest.TestCase):
    def test_assign_words_to_regions_geometric(self):
        # Un objeto no comparte espacio con el otro 
        rects = [{k_id: 0, k_x_min: 10, k_x_max: 20, k_y_min:10, k_y_max:20}]
        region = {k_id:[], k_x_min: 90, k_x_max: 250, k_y_min:50, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertEqual([], region[k_id], '')
        
        # Caso A
        rects = [{k_id: 0, k_x_min: 90, k_x_max: 250, k_y_min:50, k_y_max:300}]
        region = {k_id:[], k_x_min: 90, k_x_max: 250, k_y_min:50, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
    
        # Caso A
        rects = [{k_id: 0, k_x_min: 110, k_x_max: 230, k_y_min:70, k_y_max:275}]
        region = {k_id:[], k_x_min: 90, k_x_max: 250, k_y_min:50, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
        
        # Caso B
        rects = [{k_id: 0, k_x_min: 22, k_x_max: 50, k_y_min:20, k_y_max:50}]
        region = {k_id:[], k_x_min: 30, k_x_max: 80, k_y_min:10, k_y_max:60}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
    
        # Caso C
        rects = [{k_id: 0, k_x_min:70, k_x_max: 270, k_y_min:110, k_y_max:300}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')        
        
        # Caso D
        rects = [{k_id: 0, k_x_min:70, k_x_max: 250, k_y_min:100, k_y_max:300}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
    
        # Caso E
        rects = [{k_id: 0, k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:325}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
    
        # Caso F
        rects = [{k_id: 0, k_x_min:60, k_x_max: 250, k_y_min:95, k_y_max:300}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
        
        # Caso G
        rects = [{k_id: 0, k_x_min:70, k_x_max: 270, k_y_min:95, k_y_max:300}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
        
        # Caso H
        rects = [{k_id: 0, k_x_min:50, k_x_max:250, k_y_min:110, k_y_max:320}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')   
    
        # Caso I
        rects = [{k_id: 0, k_x_min:70, k_x_max: 275, k_y_min:110, k_y_max:320}]
        region = {k_id:[], k_x_min:70, k_x_max: 250, k_y_min:110, k_y_max:300}
        assign_words_to_regions_geometric(rects, region, k_id)
        self.assertIn(rects[0][k_id], region[k_id], '')
