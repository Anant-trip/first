package com.tyss.controller;

import java.security.Principal;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import com.tyss.dto.StudentDTO;
import com.tyss.entity.Course;
import com.tyss.entity.Student;
import com.tyss.entity.User;
import com.tyss.repo.CourseRepo;
import com.tyss.repo.StudentRepo;
import com.tyss.repo.UserRepo;
import com.tyss.service.UserService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class StudentController {

	private final UserRepo userRepo;

	private final StudentRepo studentRepo;

	private final CourseRepo courseRepo;

	private final UserService userService;

	@GetMapping("/add-student")
	public String addStudentPage(Model model, Principal principal) {

		Integer uid = userService.getUid(principal);

		List<Course> courses = courseRepo.findByUserUid(uid);

		model.addAttribute("student", new StudentDTO());
		model.addAttribute("courses", courses);

		return "add-student";
	}

	@PostMapping("/add-student")
	public String saveStudent(@ModelAttribute("student") StudentDTO dto, Principal principal) {

		Optional<User> opt = userRepo.findByEmail(principal.getName());

		if (opt.isEmpty()) {
			return "redirect:/login?msg=Please Login Again!!";
		}

		List<Course> selectedCourses = courseRepo.findAllById(dto.getCourseIds());

		Student student = new Student();
		student.setName(dto.getName());
		student.setEmail(dto.getEmail());
		student.setCourses(selectedCourses);
		student.setUser(opt.get());

		studentRepo.save(student);

		return "redirect:/dashboard?msg=Student added successfully!!";
	}

	@GetMapping("/view-students")
	public String viewStudentPage(Principal principal, Model model) {

		Integer uid = userService.getUid(principal);

		List<Student> students = studentRepo.findByUserUid(uid);

		model.addAttribute("students", students);

		return "view-students";
	}
}
