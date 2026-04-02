package com.tyss.controller;

import java.security.Principal;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tyss.dto.CourseDTO;
import com.tyss.entity.Course;
import com.tyss.entity.Student;
import com.tyss.entity.User;
import com.tyss.repo.CourseRepo;
import com.tyss.repo.StudentRepo;
import com.tyss.repo.UserRepo;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class CourseController {
	
	private final UserRepo userRepo;
	
	private final CourseRepo courseRepo;

	private final StudentRepo studentRepo;
	
	@GetMapping("/add-course")
	public String coursePage(Model model) {
		model.addAttribute("course", new CourseDTO());
		return "add-course";
	}

	@PostMapping("/add-course")
	public String addCourse(Principal principal, CourseDTO dto) {

		String email = principal.getName();

		Optional<User> opt = userRepo.findByEmail(email);

		if (opt.isEmpty()) {
			return "redirect:/login?msg=Please Login Again!!";
		}

		User user = opt.get();

		Course course = new Course();
		course.setName(dto.getName());
		course.setDuration(dto.getDuration());

		course.setUser(user);

		courseRepo.save(course);

		return "redirect:/dashboard?msg=course added successfully!!";
	}

	@GetMapping("/view-course")
	public String viewCoursePage(Principal principal, Model model) {

		Integer uid = userRepo.findByEmail(principal.getName()).get().getUid();

		List<Course> courses = courseRepo.findByUserUid(uid);

		model.addAttribute("courses", courses);

		return "view-course";
	}
	
	@GetMapping("/edit-course")
	public String editCoursePage(Model model,@RequestParam Integer cid) {
		
		Course courseEntity = courseRepo.findById(cid).get();
		
		CourseDTO course = new CourseDTO();
		
		BeanUtils.copyProperties(courseEntity, course);
		
		model.addAttribute("course", course);
		
		return "edit-course";
	}
	
	@PostMapping("/edit-course")
	public String editCourse(CourseDTO dto) {
		
		Course courseEntity = courseRepo.findById(dto.getId()).get();
		
		courseEntity.setName(dto.getName());
		courseEntity.setDuration(dto.getDuration());
		
		courseRepo.save(courseEntity);
		
		return "redirect:/dashboard?msg=course updated successfully!!";
	}
	
	@GetMapping("/delete-course")
	public String deleteCourse(@RequestParam Integer cid) {
		
		Course course = courseRepo.findById(cid).get();
		
		List<Student> students = course.getStudents();
	
		for (Student student : students) {
			List<Course> courses = student.getCourses();
			courses.remove(course);
			student.setCourses(courses);
			studentRepo.save(student);
		}
		
		courseRepo.deleteById(cid);
		
		return "redirect:/dashboard?msg=course deleted successfully!!";
	}
	
	
	
}
